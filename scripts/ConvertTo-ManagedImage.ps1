<#
.SYNOPSIS
    Converts an existing Virtual Hard Disk (VHD) blob to an Azure managed image.

.DESCRIPTION
    Converts an existing Virtual Hard Disk (VHD) blob in a defined storage account 
    container and creates an intermediate managed disk, then a managed image. The  
    script then removes the intermediate managed disk. The script does not remove the original blob. 

.PARAMETER ContainerName
    The storage account container name that contains the targeted VHD blob.

.PARAMETER Location
    The Azure region that the VHD blob is located in. This is a requirement and the 
    Azure managed disk and image must be in the same region. 

.PARAMETER PrefixFilter
    This is a blob prefix filter to identitfy the VHD blob inside the container. 
    This value comes from and is set by Packer via the capture_name_prefix Packer variable.

.PARAMETER ResourceGroupName
    The resource group name that the managed disk and image will be created in.

.PARAMETER StorageAccountName
    The storage account name that the VHD blob is located in.

.PARAMETER ImageType
    This value comes from building the original image from Packer. This is usually
    the baseline image name from a Packer/Azure Image Builder template name.
    e.g. ubuntu1804, ubuntu2004, windows2016, windows2019

.PARAMETER ImageNamePrefix
    The prefix for the managed image that will be created. This is used
    for naming the managed image resource. 
    e.g. "$ImageNamePrefix-sampleimagename"

.PARAMETER Tags
    The tags to apply to managed image. 

    Recommended tags should include the following categories:
    - Buid Id
    - Git ref
    - Git repo
    - Environment type (e.g. dev, sbx, prod, nonprod)
    - Environment use (e.g. agent)
    - Agent pool name
    - Team name
    - Workload

.NOTES
    This script uses Azure CLI and supports being run interactively 
    as well as from an Azure DevOps pipeline.

    This script leverages the --auth-mode login flag on some of the az commands, therefore
    the Azure AD identities running this script must be added to the following role assignments: 
    
        "Storage Blob Data Reader" for the storage account

    A managed disk must be created from the VHD. After the managed disk is created,
    then we can create a managed image. Packer in it's current state and implementation
    does not create a managed disk or image, just a VHD blob. Packer is capable of directly creating
    managed disks, however, we are leveraging what the GitHub product team has done to create VM images. Also,
    Packer mentions creating direct managed images are for advanced users and is not recommended. 

.EXAMPLE

    PS> .\ConvertTo-ManagedImage.ps1 -ContainerName system -Location eastus2 `
    -PrefixFilter Microsoft.Compute/Images/test-ubuntu1804/packer-12345 `
    -ResourceGroupName rg-contoso -StorageAccountName stcontoso -ImageType ubuntu1804 `
    -ImageNamePrefix contosoadoagent -Tags @(\"env=dev\",\"workload=ado agent\")

.EXAMPLE

    PS> .\ConvertTo-ManagedImage.ps1 -ContainerName system -Location eastus2 `
    -PrefixFilter Microsoft.Compute/Images/test-windows2019/packer-56789 `
    -ResourceGroupName rg-contoso -StorageAccountName stcontoso -ImageType windows2019 `
    -ImageNamePrefix contosoadoagent -Tags @(\"env=prod\",\"workload=ado agent\")

.LINK
    https://docs.microsoft.com/en-us/azure/virtual-machines/managed-disks-overview

.LINK
    https://www.packer.io/docs/builders/azure/chroot

.LINK
    https://docs.microsoft.com/en-us/azure/virtual-machines/windows/capture-image-resource

.LINK
    https://www.packer.io/docs/builders/azure/arm#capture_container_name

#>

#Requires -Version 7.0
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$ContainerName,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$Location,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$PrefixFilter,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroupName,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$StorageAccountName,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$ImageType,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [ValidatePattern("^[\w-]*$")]
    [string]$ImageNamePrefix,

    [array]$Tags
)

# Finding the specific blob (.vhd file) in storage based on prefix.
# Specifically using an array type becuase of the check of more 
# than one blob name which could occur becuase it's only the 
# prefix that's being checked and not the full blob name.
[array]$vhdName = $(az storage blob list --auth-mode login --container-name $ContainerName --account-name $StorageAccountName --prefix $PrefixFilter --query "[?contains(name, '.vhd')].name" --output tsv)
if ($vhdName.length -ne 1) {
    Write-Host "##vso[task.logissue type=error]Could not find exactly one VHD blob with prefix:'$PrefixFilter' in container:'$ContainerName'."
    exit 1 
}
Write-Host "Found existing vhd file blob..."
Write-Host "vhdName=$vhdName"

# Getting the blob details
$blobInfo = $(az storage blob show --auth-mode login --container-name $ContainerName --name $vhdName --account-name $StorageAccountName) | ConvertFrom-Json -Depth 10
if ([string]::IsNullOrEmpty($blobInfo)) {
    Write-Host "##vso[task.logissue type=error]Blob info result was null when retrieving information from container:'$ContainerName' name:'$vhdName' and account name:'$StorageAccountName'"
    exit 1
}
Write-Host "Retrieved blob information..."
Write-Host "blobInfo.name=$($blobInfo.name)"

# Creating a URL for the blob. This is needed for creating a managed disk
$blobUrl = $(az storage blob url --auth-mode login --container-name $ContainerName --name $vhdName --account-name $StorageAccountName --output tsv)
if ([string]::IsNullOrEmpty($blobUrl)) {
    Write-Host "##vso[task.logissue type=error]Could not create a URL for the blob"
    exit 1
}
Write-Host "Created URL for existing vhd blob..."
Write-Host "blobUrl=$blobUrl"
Write-Host "##vso[task.setvariable variable=blobUrl]$blobUrl"

# capture metadata associated with the blob
$blobMetadataCapturedVmKey = $blobInfo.metadata.MicrosoftAzureCompute_CapturedVMKey
Write-Host "##vso[task.setvariable variable=blobMetadataCapturedVmKey]$blobMetadataCapturedVmKey"
$blobMetadataImageType = $blobInfo.metadata.MicrosoftAzureCompute_ImageType
Write-Host "##vso[task.setvariable variable=blobMetadataImageType]$blobMetadataImageType"
$blobMetadataoOState = $blobInfo.metadata.MicrosoftAzureCompute_OSState
Write-Host "##vso[task.setvariable variable=blobMetadataoOState]$blobMetadataoOState"
$blobMetadataOSType = $blobInfo.metadata.MicrosoftAzureCompute_OSType
Write-Host "##vso[task.setvariable variable=blobMetadataOSType]$blobMetadataOSType"

$blobCreationTimeStamp = ($blobInfo.properties.creationTime).ToUniversalTime().ToString("yyyyMMddTHHmmssK")
$imageName = "{0}-{1}-{2}-{3}" -f $ImageNamePrefix.ToLower(), $blobMetadataOSType.ToLower(), $ImageType.ToLower(), $blobCreationTimeStamp

try {
    Write-Host "Creating new Azure managed disk with image name:$imageName"
    $diskCreateResult = $(az disk create `
        --resource-group $ResourceGroupName `
        --location $Location `
        --name $imageName `
        --source $blobUrl `
        --hyper-v-generation V2 `
        --os-type $blobMetadataOSType) `
        | ConvertFrom-Json -Depth 10
    Write-Host ($diskCreateResult | Format-List | Out-String)

    Write-Host "Creating new Azure managed image with image name:$imageName"
    $imageCreateResult = $(az image create `
        --name $imageName `
        --resource-group $ResourceGroupName `
        --source $diskCreateResult.id `
        --hyper-v-generation V2 `
        --location $Location `
        --os-type $blobMetadataOSType `
        --tags ${Tags}) `
    | ConvertFrom-Json
    Write-Host ($imageCreateResult | Format-List | Out-String)

    Write-Host "Setting imageName variable to: '$imageName'"
    Write-Host "##vso[task.setvariable variable=imageName]$imageName"
    Write-Host "Setting managedImageResouceId variable to: '$($imageCreateResult.id)'"
    Write-Host "##vso[task.setvariable variable=managedImageResouceId]$($imageCreateResult.id)"
    Write-Host "Setting blobMetadataCapturedVmKey variable to: '$blobMetadataCapturedVmKey'"
    Write-Host "##vso[task.setvariable variable=blobMetadataCapturedVmKey]$blobMetadataCapturedVmKey"
    Write-Host "Setting blobMetadataImageType variable to: '$blobMetadataImageType'"
    Write-Host "##vso[task.setvariable variable=blobMetadataImageType]$blobMetadataImageType"
    Write-Host "Setting blobMetadataoOState variable to: '$blobMetadataoOState'"
    Write-Host "##vso[task.setvariable variable=blobMetadataoOState]$blobMetadataoOState"
    Write-Host "Setting blobMetadataOSType variable to: '$blobMetadataOSType'"
    Write-Host "##vso[task.setvariable variable=blobMetadataOSType]$blobMetadataOSType"
} catch {
    Write-Host "##vso[task.logissue type=error]There was an error creating the managed disk and or managed image"
    Write-Host $_
    Write-Host "Attempting to clean up resources..."
} finally {
    Write-Host "Cleaning up and removing the managed disk"
    if (($diskCreateResult.provisioningState) -eq "Succeeded") {
        az disk delete --ids $diskCreateResult.id --yes
    } else {
        Write-Host "##vso[task.logissue type=warning]Delete will not be performed due to errors during creation. Provisioning state was not 'Succeeded'."
    }
}
