

az group create --name mijohns-agent --location "eastus2"


# az deployment group what-if `
#     --name exampldeployment `
#     --resource-group mijohns-agent `
#     --template-file main.bicep `
#     --parameters vnetName='vnet-adoagenttemp-sbx-eastus2' registryName='acr-agenttemp'

az deployment group create `
    --resource-group mijohns-agent `
    --template-file main.bicep `
    --parameters vnetName='vnet-adoagenttemp-sbx-eastus2' registryName='acragenttemp'
    