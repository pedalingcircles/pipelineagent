
#Requires -Version 5.1
<#
.Synopsis
    Deletes intermediate resources that were created during the VM Image creation process.

.DESCRIPTION
    Deletes (cleans) up resources that were created while generating a VM IMage using Packer
    and the conversion from a VHD blob to an Azure Managed Image.  

.PARAMETER DestinationContainerName
    The container that's used by Packer during image creation. This will likely 
    be called "images"

.PARAMETER WorkingContainerName
    The container that's used by Packer after the image is created and the 
    result of the creation process. 

.PARAMETER DateVersionCounter
    Every increasing counter that should increment everytime unless the
    DateVersion is updated.

.PARAMETER Location
    The Azure region that the vhd blob is in. This is a requirement and the 
    Azure managed disk and image must be in the same region. 

.PARAMETER Prefix
    This is the full path of the vhd blob inside the container. 
    example: "Microsoft.Compute/Images/images/23792"

.PARAMETER ResourceGroupName
    The resource group name that the managed disk and image will be created in.

.PARAMETER StorageAccountName
    The storage account name that the VHD blob is located in.

.NOTES
    This script uses Azure CLI.

    This script leveraging extensive tagging on resources in order to identify 
    what can be removed. 

    This script re-tries attempts to delete resources due to transient errors while 
    trying to delete resources. In addition, it first deletes the the managed disk 
    then deleted container blobs in that order due to the vhd being the source of 
    of the other resources. 

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
  [string][Parameter(Mandatory=$true)]$DestinationContainerName,
  [string][Parameter(Mandatory=$true)]$WorkingContainerName,
  [string][Parameter(Mandatory=$false)]$Prefix,
  [string][Parameter(Mandatory=$false)]$StorageAccountName
)

# First getting the blob with the prefix to gather metadata 
# to find out what to delete.

$vhdName = az storage blob list --auth-mode login --container-name $DestinationContainerName --account-name $StorageAccountName --prefix $Prefix --query "[?contains(name, '.vhd')].name | [0]" -o tsv
if ([string]::IsNullOrEmpty($vhdName)) {
    Write-Host "##vso[task.logissue type=error]VHD blob with prefix:'$Prefix' not found in container:'$DestinationContainerName'"
    exit 1
}
Write-Host "vhdName=$vhdName"

# Getting the blob details
try {
    $blobInfo = az storage blob show --auth-mode login --container-name $DestinationContainerName --name $vhdName --account-name $StorageAccountName | ConvertFrom-Json
} catch {
    Write-Verbose $_
    Write-Host "##vso[task.logissue type=error]Error in retrieving blob information"
    exit 1
}

# Set metadata
$capturedVMKey = $blobInfo.metadata.MicrosoftAzureCompute_CapturedVMKey

# Find values based on the resource path
$metaArray = $capturedVMKey -split "/"
$workingVmName = "{0}.{1}" -f $metaArray[6], "vhd"

# delete working blob

$result = az storage blob delete `
    --container-name $WorkingContainerName `
    --account-name $StorageAccountName `
    --name $workingVmName `
    --auth-mode login `
    2>&1
if ($LastExitCode -ne 0) {
    Write-Error "Error deleting blob"
    exit 1
}

Write-Host ($deleteResults | Format-List | Out-String)






