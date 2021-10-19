[CmdletBinding()]
param(
    [String] [Parameter (Mandatory=$true)] $ResourceGroupName,
    [String] [Parameter (Mandatory=$true)] $Location,
    [String] [Parameter (Mandatory=$true)] $TemplateFilePath,
    [String] [Parameter (Mandatory=$true)] $TemplateParameterFilePath
)

az group create --name $ResourceGroupName --location $Location

az deployment group create `
    --resource-group $ResourceGroupName `
    --template-file $TemplateFilePath `
    --parameters $TemplateParameterFilePath `
    --parameters adminPublicKey=$adminPublicKey agentToken=$pat

    