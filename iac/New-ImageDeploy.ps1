
$resourceGroupName = "rg-contoso-agentimages"
$location = "eastus2"

az group create --name $resourceGroupName --location $location

az deployment group create `
    --resource-group $resourceGroupName `
    --template-file image.bicep `
    --parameters image.parameters.sbx.json
    