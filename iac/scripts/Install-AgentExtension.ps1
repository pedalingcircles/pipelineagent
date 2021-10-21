
[CmdletBinding()]
param(
    [String] [Parameter (Mandatory=$true)] $AzpAgentName,
    [String] [Parameter (Mandatory=$true)] $AzpAgentPool,
    [String] [Parameter (Mandatory=$true)] $AzpPatToken,
    [String] [Parameter (Mandatory=$true)] $AzpUrl,
    [String] [Parameter (Mandatory=$true)] $AgentVersion
)

Write-Host "This is placeholder script to automate the installation of a windows agent."