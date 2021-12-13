#Requires -Version 7.0
<#
.Synopsis
    Creates a new baseline virtual machine (VM) image used by Azure DevOps Pipelines agents.
.DESCRIPTION
    Creates a new baseline virtual machine (VM) image used by Azure DevOps Pipelines agents. 
    
    HashiCorp Packer is used as the tool to generate virtual machine (VM) images. This script coordinates the 
    various parameters used to call the Packer binary and then calls the binary
    to leverage the various supported templates in this repository.

.PARAMETER OsType
    The OS type which represents the valid path under the images folder.
    Validate values are "win" for Windows, "linux" for Linux and "macos" for macOS.

.PARAMETER BuildResourceGroupName
    An existing resource group to run the Packer Image build in.

.PARAMETER ResourceGroupName
    An existing resource group under which the final artifact will be stored.

.PARAMETER ImageGenerationRepositoryRoot
    The root path of the Packer templates.

.PARAMETER ImageType
    The type of image being generated. 
    Valid options are: "windows2016", "test-windows2016", "windows2019", "test-windows2019", "windows2022", "test-windows2022", "ubuntu1804","test-ubuntu1804","ubuntu2004", "test-ubuntu2004".

.PARAMETER CaptureNamePrefix
    The prefix given to the blob name produced from the image build.

.PARAMETER TenantId
    The Active Directory tenant Id.

.PARAMETER StorageAccountName
    Storage account under which the final artifact will be stored.

.PARAMETER VnetName
    A pre-existing virtual network used by 
    Packer while the virtual machine (VM) image is being built.

.PARAMETER VnetResourceGroupName
    The resource group for the pre-existing virtual network for the virtual machine (VM) image building.

.PARAMETER VnetSubnetName
    The sbunet name in the pre-existing virtual network for the virtual machine (VM).

.PARAMETER UseAzureCliAuth
    A switch when if set, sets the value of "use_azure_cli_auth" to true, false otherwise.

.PARAMETER PublicIp
    A switch when if set, sets Packer to use a public IP address when building
    images. This is generally only used to support building images from a 
    user's machine sitting outside of a protected network.

.NOTES
    It's assumed that this script is run from an Azure DevOps pipeline, but can also
    be run interactively from a user's machine.

.LINK
https://www.packer.io/docs/builders/azure
https://github.com/actions/virtual-environments
https://www.packer.io/docs/builders/azure/arm#use_azure_cli_auth
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("linux", "win", "macos")]
    [string]$OsType,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$BuildResourceGroupName,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroupName,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$ImageGenerationRepositoryRoot,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet("windows2016", "test-windows2016", "windows2019", "test-windows2019", "windows2022", "test-windows2022", "ubuntu1804","test-ubuntu1804","ubuntu2004", "test-ubuntu2004")]
    [string]$ImageType,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$CaptureNamePrefix,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$TenantId,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$StorageAccountName,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$VnetName,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$VnetResourceGroupName,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$VnetSubnetName,

    [switch]$UseAzureCliAuth, 

    [switch]$PublicIp
)

$relativeTemplatePath = Join-Path $OsType ($ImageType + ".json")



switch ($ImageType) {
    ("windows2016") {
        $relativeTemplatePath = Join-Path "win" "windows2016.json"
    }
    ("test-windows2016") {
        $relativeTemplatePath = Join-Path "win" "test-windows2016.json"
    }
    ("windows2019") {
        $relativeTemplatePath = Join-Path "win" "windows2019.json"
    }
    ("test-windows2019") {
        $relativeTemplatePath = Join-Path "win" "test-windows2019.json"
    }
    ("windows2022") {
        $relativeTemplatePath = Join-Path "win" "windows2022.json"
    }
    ("test-windows2022") {
        $relativeTemplatePath = Join-Path "win" "test-windows2022.json"
    }
    ("ubuntu1804") {
        $relativeTemplatePath = Join-Path "linux" "ubuntu1804.json"
    }
    ("test-ubuntu1804") {
        $relativeTemplatePath = Join-Path "linux" "test-ubuntu1804.json"
    }
    ("ubuntu2004") {
        $relativeTemplatePath = Join-Path "linux" "ubuntu2004.json"
    }
    ("test-ubuntu2004") {
        $relativeTemplatePath = Join-Path "linux" "test-ubuntu2004.json"
    }
    default {
        Write-Host "##vso[task.logissue type=error]Unknown type of image"
    }
}

# OS Type based on first part of 
# path where images are located
$delimiter = $IsWindows ? "\\" : "/"
$osType = ($relativeTemplatePath -split $delimiter)[0]

$imageTemplatePath = [IO.Path]::Combine($ImageGenerationRepositoryRoot, "images", $relativeTemplatePath)

$publicIpPackerSettings = "false"
if ($PublicIp) {
    $publicIpPackerSettings = "true"
}

if (-not (Test-Path $imageTemplatePath)) {
    Write-Host "##vso[task.logissue type=error]Template for image '$ImageType' doesn't exist on path '$imageTemplatePath'"
}

$packerBinary = Get-Command "packer"
if (-not ($packerBinary)) {
    Write-Host "##vso[task.logissue type=error]'packer' binary is not found on PATH"
    throw "'packer' binary is not found on PATH"
}

# Set up Packer to log
$env:PACKER_LOG=1
$dateStamp = (Get-Date).ToUniversalTime().ToString("yyyyMMddTHHmmssK")
$env:PACKER_LOG_PATH="packer-$($dateStamp).log"

$azureCliAuth = $UseAzureCliAuth ? "true" : "false"

$startPackerMeasure = (Get-Date)
switch ($osType ) {
    ("win") {
        $InstallPassword = $env:UserName + [System.GUID]::NewGuid().ToString().ToUpper()

        & $packerBinary build -on-error=cleanup `
        -var "install_password=$($InstallPassword)" `
        -var "tenant_id=$($TenantId)" `
        -var "resource_group=$($ResourceGroupName)" `
        -var "storage_account=$($StorageAccountName)" `
        -var "build_resource_group_name=$($BuildResourceGroupName)" `
        -var "capture_name_prefix=$($CaptureNamePrefix)" `
        -var "virtual_network_name=$($VnetName)" `
        -var "virtual_network_resource_group_name=$($VnetResourceGroupName)" `
        -var "virtual_network_subnet_name=$($VnetSubnetName)" `
        -var "private_virtual_network_with_public_ip=$($publicIpPackerSettings)" `
        -var "use_azure_cli_auth=$($azureCliAuth)" `
        $imageTemplatePath

        $InstallPassword = $null
    }
    ("linux") {
        & $packerBinary build -on-error=cleanup `
        -var "tenant_id=$($TenantId)" `
        -var "resource_group=$($ResourceGroupName)" `
        -var "storage_account=$($StorageAccountName)" `
        -var "build_resource_group_name=$($BuildResourceGroupName)" `
        -var "capture_name_prefix=$($CaptureNamePrefix)" `
        -var "virtual_network_name=$($VnetName)" `
        -var "virtual_network_resource_group_name=$($VnetResourceGroupName)" `
        -var "virtual_network_subnet_name=$($VnetSubnetName)" `
        -var "private_virtual_network_with_public_ip=$($publicIpPackerSettings)" `
        -var "use_azure_cli_auth=$($azureCliAuth)" `
        $imageTemplatePath
    }
    ("macos") {
        Write-Host "##vso[task.logissue type=error]Mac OS images are not yet supported"
    }
    default {
        Write-Host "##vso[task.logissue type=error]Unknown type of OS Type"
    }
}
$endPackerMeasure = (Get-Date)

Write-Host "Packer build completed and took..." 
$($endPackerMeasure - $startPackerMeasure)
Write-Host "...to run"