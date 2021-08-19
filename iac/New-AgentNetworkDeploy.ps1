
$resourceGroupName = "rg-mijohns-agents-sbx-eastus2-001"
$location = "eastus2"

az group create --name $resourceGroupName --location $location

az deployment group create `
    --resource-group $resourceGroupName `
    --template-file agents-network.bicep `
    --parameters agents-network.parameters.sbx.json
    