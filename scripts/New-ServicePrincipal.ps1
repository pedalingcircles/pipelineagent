#Requires -Version 5.0 -Modules AzureAD, AZ

<#
.Synopsis
    Creates a new baseline virtual machine (VM) image  used by Azure DevOps Pipelines agents.
.DESCRIPTION
    Create a new baseline image for Azure DevOps Pipelines agents. This script uses the built in
    Azure VM images for both Windows and Linux. This script doesn't support custom baseline images
    that are not available in Azure.

    This script assumes the resource group and a service principal have already been setup based
    on best practices of limited scope.

    It's assumed that this script is run from an Azure DevOps Pipeline, but can also
    be run interactively from a user's machine.

.PARAMETER ServicePrincipalClientId
    The Active Directory service principal associated with the builder.

.PARAMETER ServicePrincipalClientSecret
    The password or secret for the service principal.

.PARAMETER SubscriptionId
The Azure subscription Id where resources will be created.

.PARAMETER TenantId
    The Active Directory tenant identifier with which your 
    ServicePrincipalClientId and SubscriptionId are associated.

.PARAMETER ResourceGroupName
    Resource group under which the final artifact will be stored.

.PARAMETER StorageAccountName
    Storage account under which the final artifact will be stored.

.PARAMETER BuildResourceGroupName
    An existing resource group to run the build in.

.PARAMETER VnetName
    A pre-existing virtual network for the VM.

.PARAMETER VnetResourceGroupName
    The resource group for the pre-existing virtual network for the VM.

.PARAMETER VnetSubnetName
    The sbunet name in the pre-existing virtual network for the VM.

.PARAMETER ImageGenerationRepositoryRoot
    The root path of the image generation repository source.

.PARAMETER ImageType
    The type of the image being generated. Valid options are: {"Windows2016", "Windows2019", "Ubuntu1604", "Ubuntu1804"}.

.NOTES

#>

[CmdletBinding()]
param(
    [String] [Parameter (Mandatory=$true)] $Subscription,
    [String] [Parameter (Mandatory=$true)] $Tenant,
    [String] [Parameter (Mandatory=$true)] $DisplayName,
    [String] [Parameter (Mandatory=$true)] $DistinguishedName,
    [String] [Parameter (Mandatory=$true)] $KeyFriendlyName,
    [String] [Parameter (Mandatory=$true)] $ResourceGroup,
    [String] [Parameter (Mandatory=$true)] $GroupName

)

# Creating a self signed certificate to be associated with an Azure AD App Registration
$cert = New-SelfSignedCertificate `
    -Subject $DistinguishedName `
    -CertStoreLocation "cert:\CurrentUser\My" `
    -KeyAlgorithm RSA `
    -KeyFriendlyName $KeyFriendlyName `
    -KeyLength 2048 `
    -KeyExportPolicy Exportable `
    -KeySpec Signature

Write-Host "Created new self-signed certificate with thumbprint: $($cert.Thumbprint)"

$keyValue = [System.Convert]::ToBase64String($cert.GetRawCertData())

# Creating a new service principal. This also creates the corresponding App Registration 
# and associates the self-signed certificate with it. It uses the default start and end dates from the certificate.
$sp = New-AzADServicePrincipal -DisplayName $DisplayName -CertValue $keyValue -EndDate $cert.NotAfter -StartDate $cert.NotBefore

Write-Host "Service principal and app registration created"
Write-Host ($sp | Format-Table | Out-String)

# It may take several moments for the service principal and app registration to be created in the tenant.
Start-Sleep 20

# Optionally assign the app reg to an Azure AD group that has the appropriate RBAC
$group = Get-AzureADGroup -SearchString $GroupName
Add-AzureADGroupMember -ObjectId $sp.Id -RefObjectId $group.Id

# Clean up certificate in local store
Write-Host "Completed creating service principal"
