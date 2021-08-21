
$resourceGroupName = "rg-mijohns-agents-sbx-eastus2-001"

#az group create --name $resourceGroupName --location $location

az deployment group create `
    --resource-group $resourceGroupName `
    --template-file agent-vmimage.bicep `
    --parameters agent-vmimage.parameters.sbx.json
    