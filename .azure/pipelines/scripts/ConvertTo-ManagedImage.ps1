#Requires -Version 5.1
<#
.Synopsis
    Converts an existing VHD file as a blob to an Azure managed image.

.DESCRIPTION
    This script is intented to be run as part of a pipeline that generates Azure managed images using
    Packer. Packer, as implemented, just creates a vhd file. This file must be converted to a managed
    disk, then converted to a managed image. This script handles the conversation. 

    In addition, after conversion, this script cleans up resources after the migration. This 
    includes the original VHD file, but also the managed disk and managed image.

.PARAMETER ContainerName
    The storage account container name that contains the targeted vhd blob.

.PARAMETER DateVersion
    A version of the image based on date. The recommended format is: yyyymmdd

.PARAMETER DateVersionCounter
    Every increasing counter that should increment everytime unless the
    DateVersion is updated.

.PARAMETER Location
    The Azure region that the vhd blob is in. This is a requirement and the 
    Azure managed disk and image must be in the same region. 

.PARAMETER Prefix
    This is the full path of the vhd blob inside the container. 
    This value comes from and is set by the Packer via
    the capture_name_prefix Packer variable.
    example: "Microsoft.Compute/Images/images/23792".

.PARAMETER ResourceGroupName
    The resource group name that the managed disk and image will be created in.

.PARAMETER StorageAccountName
    The storage account name that the VHD blob is located in.

.PARAMETER ImageType
    This value comes from building the original image from Packer. This is usually
    the baseline image name from a Packer/Azure Image Builder template name. 
    e.g. ubuntu1804, ubuntu2004, windows2016, windows2019

.PARAMETER Tags
    The tags to apply to the blob, Azure Managed Disk and Azure Managed Image. 
    Recommended tags should include the following categories:
    - Buid Id
    - Build run
    - Environment type (e.g. dev, sbx, prod, nonprod)
    - prefix
    - Environment use (e.g. agent)
    - Pool name
    - Team name 
    - Portfolio name

    Tags are name value pairs seperated by a single white space
    example:key1=value1 key2=value2 key3=value3

.NOTES
    This script uses Azure CLI.

    This script leverages the --auth-mode login flag on some of the az commands, therefore
    the user or service principles running this script must be added to the following role assignments: 
    
        "Storage Blob Data Contributor"
        "Storage Blob Data Reader"
        "Storage Queue Data Contributor"
        "Storage Queue Data Reader"

.LINK
    https://docs.microsoft.com/en-us/azure/virtual-machines/windows/capture-image-resource

.LINK
    https://docs.microsoft.com/en-us/azure/virtual-machines/managed-disks-overview

#>

[CmdletBinding()]
param(
  [string][Parameter(Mandatory=$true)]$ContainerName,
  [string][Parameter(Mandatory=$false)]$DateVersion,
  [string][Parameter(Mandatory=$false)]$DateVersionCounter,
  [string][Parameter(Mandatory=$false)]$Location,
  [string][Parameter(Mandatory=$false)]$Prefix,
  [string][Parameter(Mandatory=$false)]$ResourceGroupName,
  [string][Parameter(Mandatory=$false)]$StorageAccountName,
  [string][Parameter(Mandatory=$false)]$ImageType,
  [string][Parameter(Mandatory=$false)]$Tags,
  [switch]$Clean
)

# Finding the specific blob (.vhd file) in storage based on prefix. 
[array]$vhdName = az storage blob list --auth-mode login --container-name $ContainerName --account-name $StorageAccountName --prefix $Prefix --query "[?contains(name, '.vhd')].name"  -o tsv
if ($vhdName.length -ne 1) {
    Write-Host "##vso[task.logissue type=error]VHD blob with prefix:'$Prefix' not found in container:'$ContainerName' or more than one blob exists with the same prefix."
    exit 1 
}
Write-Host "Found existing vhd file blob..."
Write-Host "vhdName=$vhdName"

# Getting the blob details
try {
    $blobInfo = az storage blob show --auth-mode login --container-name $ContainerName --name $vhdName --account-name $StorageAccountName | ConvertFrom-Json
    if ($null -eq $blobInfo) {
        throw "Blob info result was null when retieving information from container:$ContainerName name:$vhdName and account name:$StorageAccountName"
    }
} catch {
    Write-Host $_
    Write-Host "##vso[task.logissue type=error]Error in retrieving blob information"
    exit 1
}
Write-Host "Retrieved blob information..."
Write-Host $blobInfo

# Creating a URL for the blob. This is needed for creating a managed disk
$blobUrl = az storage blob url --auth-mode login --container-name $ContainerName --name $vhdName --account-name $StorageAccountName
if ([string]::IsNullOrEmpty($blobUrl)) {
    Write-Host "##vso[task.logissue type=error]Could not create a URL for the blob"
    exit 1
}
Write-Host "Created URL for existing vhd blob..."
Write-Host "blobUrl=$blobUrl"

# Set metadata
$osType = $blobInfo.metadata.MicrosoftAzureCompute_OSType

# A managed disk must be created from the VHD. After the managed disk is created
# then we can create a managed image. Note: Packer in it's current state and implementation
# does not create a managed disk or imaged. Just a VHD file. Packer is capabile of directly creating
# managed disk, however, we are leveraging what the ADO team has done to create VM images.
$imageName = "{0}-{1}-{2}.{3}" -f "packer", $ImageType, "$DateVersion", "$DateVersionCounter"
Write-Host "Creating new Azure managed disk with image name:$imageName"

# This is an intermediate resource (Azure Managed Disk) that's used
# to ultimatly create an Azure Managed Image. This resource will therefore
# be deleted after the Azure Managed Image is created.
# Wrapping both disk and image creation in try block so 
# we can clean up if one or both fail in finally.
try {
    $diskCreateResult = az disk create `
    --resource-group $ResourceGroupName `
    --location $Location `
    --name $imageName `
    --source $blobUrl `
    --os-type $osType `
    --tags envtype=sbx envuse=agents prefix=$Prefix
    | ConvertFrom-Json
    Write-Host "Created new managed disk..."
    Write-Host ($diskCreateResult | Format-List | Out-String)

    $imageCreateResult = az image create `
    --name $imageName `
    --resource-group $ResourceGroupName `
    --source $diskCreateResult.id `
    --hyper-v-generation V2 `
    --location $Location `
    --os-type $osType `
    --os-type Linux `
    --tags envtype=sbx envuse=agents prefix=$Prefix `
    | ConvertFrom-Json
    Write-Host "Created new managed image..."
    Write-Host ($imageCreateResult | Format-List | Out-String)
} catch {
    Write-Host "##vso[task.logissue type=error]There was an error creating the managed disk and or managed image"
    Write-Host $_
    Write-Host "Attempting to clean up resources..."
} finally {
    Write-Host "Cleaning up and removing the managed disk"
    if ($diskCreateResult.provisioningState -eq "Succeeded" -and $Clean) {
        az disk delete --ids $diskCreateResult.id --yes
    } else {
        Write-Host "##vso[task.logissue type=warning]Could not clean up the managed disk. This could be due to errors during creation or the 'Clean' switch wasn't set."
    }

    # Only clean original blobs in the storage container  if we know the managed image was created.
    if ($imageCreateResult.provisioningState -eq "Succeeded" -and $Clean) {
        # Cleaning up blobs directly related to the image creation
        az storage blob delete-batch --source $ContainerName --auth-mode login --account-name $StorageAccountName --pattern '24000*' #  $Prefix

        # Cleaning up blobs associated with working vm images. These are throw away and only needed while Packer is building an image
        $modifiedDate = (Get-Date -AsUTC -Date ((Get-Date).AddDays(-7)) -Format s) + "Z"
        Write-Host "Cleaning up all blobs in the 'images' container since $modifiedDate"
        az storage blob delete-batch --source images --auth-mode login --pattern *.vhd --account-name $StorageAccountName --if-unmodified-since $modifiedDate
    } else {
        Write-Host "##vso[task.logissue type=warning]Could not clean up the working vhd blobs in the 'images' container. This could be due errors in access or the 'Clean' switch wasn't set."
    }
}
