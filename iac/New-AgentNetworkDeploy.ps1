
$resourceGroupName = "rg-mijohns-agents-sbx-eastus2-001"
$location = "eastus2"

az group create --name $resourceGroupName --location $location

az deployment group create `
    --resource-group $resourceGroupName `
    --template-file agent-network.bicep `
    --parameters agent-network.parameters.sbx.json
    