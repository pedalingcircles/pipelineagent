
$resourceGroupName = "rg-contoso-agentimages"
$location = "eastus2"

az group create --name $resourceGroupName --location $location

az deployment group create `
    --resource-group $resourceGroupName `
    --template-file images.bicep `
    --parameters images.parameters.sbx.json
    