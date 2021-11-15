<#
.Synopsis
    Creates a new baseline virtual machine (VM) image  used by Azure DevOps Pipelines agents.
.DESCRIPTION
    Create a new baseline image for Azure DevOps Pipelines agents. This script uses the built in
    Azure VM images for both Windows and Linux. This script doesn't support custom baseline images
    that are not available in Azure.

    This script assumes the resource group and a service principle have already been setup based
    on best practices of limited scope.

    It's assumed that this script is run from an Azure DevOps Pipeline, but can also
    be run interactively from a user's machine.

.PARAMETER SubscriptionId
The Azure subscription Id where resources will be created.

.PARAMETER BuildResourceGroupName
    An existing resource group to run the build in.

.PARAMETER CaptureContainerName
    Destination container name. Essentially the "directory" where your 
    VHD will be organized in Azure. The captured VHD's URL will be
    https://<storage_account>.blob.core.windows.net/system/Microsoft.Compute/Images/<capture_container_name>/<capture_name_prefix>.xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx.vhd

.PARAMETER ResourceGroupName
    Resource group under which the final artifact will be stored.

.PARAMETER ImageGenerationRepositoryRoot
    The root path of the image generation repository source.

.PARAMETER ImageType
    The type of the image being generated. Valid options are: {"Windows2016", "Windows2019", "Ubuntu1604", "Ubuntu1804"}.

.PARAMETER ServicePrincipalClientId
    The type of the image being generated. Valid options are: {"Windows2016", "Windows2019", "Ubuntu1604", "Ubuntu1804"}.

.PARAMETER ServicePrincipalObjectId
    The type of the image being generated. Valid options are: {"Windows2016", "Windows2019", "Ubuntu1604", "Ubuntu1804"}.

.PARAMETER ServicePrincipalClientSecret
    The type of the image being generated. Valid options are: {"Windows2016", "Windows2019", "Ubuntu1604", "Ubuntu1804"}.


.PARAMETER AzureLocation
    The location of the resources being created in Azure. For example "East US".

.PARAMETER StorageAccountName
    Storage account under which the final artifact will be stored.

.NOTES

    There must be RBAC Owner to the BuildResourceGroupName

    see: https://www.packer.io/docs/builders/azure/arm

#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$SubscriptionId,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$BuildResourceGroupName,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$CaptureContainerName,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroupName,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$ImageGenerationRepositoryRoot,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet("Windows2016","Windows2019","Windows2022","Ubuntu1804","Ubuntu2004")]
    [string]$ImageType,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$ServicePrincipalClientId,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$ServicePrincipalObjectId,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [securestring]$ServicePrincipalClientSecret,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$TenantId,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$StorageAccountName
)

switch ($ImageType) {
    ("Windows2016") {
        $relativeTemplatePath = Join-Path "win" "windows2016.json"
    }
    ("Windows2019") {
        $relativeTemplatePath = Join-Path "win" "windows2019.json"
    }
    ("Windows2022") {
        $relativeTemplatePath = Join-Path "win" "windows2022.json"
    }
    ("Ubuntu1804") {
        $relativeTemplatePath = Join-Path "linux" "ubuntu1804.json"
    }
    ("Ubuntu2004") {
        $relativeTemplatePath = Join-Path "linux" "ubuntu2004.json"
    }
    default {
        Write-Host "##vso[task.logissue type=error]Unknown type of image"
    }
}

$installPassword = $env:UserName + [System.GUID]::NewGuid().ToString().ToUpper();
$imageTemplatePath = [IO.Path]::Combine($ImageGenerationRepositoryRoot, "images", $relativeTemplatePath)

if (-not (Test-Path $imageTemplatePath)) {
    Write-Host "##vso[task.logissue type=error]Template for image '$ImageType' doesn't exist on path '$imageTemplatePath'"
}

$packerBinary = Get-Command "packer"
if (-not ($packerBinary)) {
    Write-Host "##vso[task.logissue type=error]'packer' binary is not found on PATH"
    throw "'packer' binary is not found on PATH"
}

$env:PACKER_LOG=1
$env:PACKER_LOG_PATH="packerlog.txt"

& $packerBinary build -on-error=cleanup `
    -var "client_id=$($ServicePrincipalClientId)" `
    -var "client_secret=$($ServicePrincipalClientSecret)" `
    -var "subscription_id=$($SubscriptionId)" `
    -var "build_resource_group_name=$($BuildResourceGroupName)" `
    -var "capture_container_name=$($CaptureContainerName)" `
    -var "tenant_id=$($TenantId)" `
    -var "object_id=$($ServicePrincipalObjectId)" `
    -var "resource_group=$($ResourceGroupName)" `
    -var "storage_account=$($StorageAccountName)" `
    -var "install_password=$($installPassword)" `
    $imageTemplatePath

Write-Host "Packer build completed"
