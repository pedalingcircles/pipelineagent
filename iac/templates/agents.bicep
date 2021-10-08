// scope
targetScope = 'subscription'

// Can optionally use resource group here as a scope
param uniqueId string = uniqueString(deployment().name)

param envType string
param organization string
param workload string = 'pipelineagent'
param resourceAffix string = '${workload}-${uniqueId}'
param nowUtc string = utcNow()
param hubResourceGroupName string = 'rg-${resourceAffix}-hub'
param hubSubscriptionId string = subscription().subscriptionId
param hubLocation string = deployment().location

param Hubtags object = {
  'envtype': envType
  'org': organization
  'workload': workload
  'networkcomponent': 'hub'
}

module hubResourceGroup './modules/resourceGroup.bicep' = {
  name: 'deploy-hub-rg-${nowUtc}'
  scope: subscription(hubSubscriptionId)
  params: {
    name: hubResourceGroupName
    location: hubLocation
    tags: Hubtags
  }
}





