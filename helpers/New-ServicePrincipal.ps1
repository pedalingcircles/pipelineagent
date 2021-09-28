#Requires -Version 5.0 -Modules AzureAD, AZ

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

Write-Host "Service principle and app registration created"
Write-Host ($sp | Format-Table | Out-String)

# It may take several moments for the service principal and app registration to be created in the tenant.
Start-Sleep 20

# Optionally assign the app reg to an Azure AD group that has the appropriate RBAC
$group = Get-AzureADGroup -SearchString $GroupName
Add-AzureADGroupMember -ObjectId $sp.Id -RefObjectId $group.Id

# Clean up certificate in local store
Write-Host "Completed creating service principal"
