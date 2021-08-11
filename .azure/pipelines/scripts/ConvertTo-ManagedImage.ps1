see: https://wwpss.visualstudio.com/Aware/_git/pipelineagent?path=%2F.pipelines%2Fci-baselineimage.yml&version=GBmijohns%2Fhardenimageandclean&line=166&lineEnd=167&lineStartColumn=1&lineEndColumn=1&lineStyle=plain&_a=contents


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
  [string][Parameter(Mandatory=$false)]$Tags
)

# Finding the specific blob (.vhd file) in storage based on prefix. 
$vhdName = az storage blob list --auth-mode login --container-name $ContainerName --account-name $StorageAccountName --prefix $Prefix --query "[?contains(name, '.vhd')].name | [0]" -o tsv
if ([string]::IsNullOrEmpty($vhdName)) {
    Write-Host "##vso[task.logissue type=error]VHD blob with prefix:'$Prefix' not found in container:'$ContainerName'"
    exit 1
}
Write-Host "vhdName=$vhdName"

# Getting the blob details
try {
    $blobInfo = az storage blob show --auth-mode login --container-name $ContainerName --name $vhdName --account-name $StorageAccountName | ConvertFrom-Json
} catch {
    Write-Verbose $_
    Write-Host "##vso[task.logissue type=error]Error in retrieving blob information"
    exit 1
}

# Creating a URL for the blob. This is needed for creating a managed disk
$blobUrl = az storage blob url --auth-mode login --container-name $ContainerName --name $vhdName --account-name $StorageAccountName
if ([string]::IsNullOrEmpty($blobUrl)) {
    Write-Host "##vso[task.logissue type=error]Cloud not create a URL for the blob"
    exit 1
}
Write-Host "vhdName=$vhdName"

# Set metadata
$capturedVMKey = $blobInfo.metadata.MicrosoftAzureCompute_CapturedVMKey
$osType = $blobInfo.metadata.MicrosoftAzureCompute_OSType

# A managed disk must be created from the VHD. After the managed disk is created
# then we can create a managed image. Note: Packer in it's current state and implementation
# does not create a managed disk or imaged. Just a VHD file. Packer is capabile of directly creating
# managed disk, however, we are leveraging what the ADO team has done to create VM images.
$imageName = "{0}-{1}-{2}.{3}" -f "packer", "ubuntu1804", "$DateVersion", "$DateVersionCounter"

# This is an intermediate resource (Azure Managed Disk) that's used
# to ultimatly create an Azure Managed Image. This resource will therefore
# be deleted after the Azure Managed Image is created.
$diskCreateResult = az disk create `
    --resource-group $ResourceGroupName `
    --location $Location `
    --name $imageName `
    --source $blobUrl `
    --os-type $osType `
    --tags envtype=sbx envuse=agents prefix=$Prefix
    | ConvertFrom-Json
Write-Verbose ($diskCreateResult | Format-List | Out-String)

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
Write-Verbose ($imageCreateResult | Format-List | Out-String)
Write-Host 'Completed creating the managed disk: $imageName'


