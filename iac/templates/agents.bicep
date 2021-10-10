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
param agentResourceGroupName string = 'rg-${resourceAffix}-agent'
param imageBuilderResourceGroupName string = 'rg-${resourceAffix}-imagebuilder'
param imageResourceGroupName string = 'rg-${resourceAffix}-image'
param opsResourceGroupName string = 'rg-${resourceAffix}-ops'

param hubSubscriptionId string = subscription().subscriptionId
param agentSubscriptionId string = subscription().subscriptionId
param imageBuilderubscriptionId string = subscription().subscriptionId
param imageSubscriptionId string = subscription().subscriptionId
param opsSubscriptionId string = subscription().subscriptionId

param hubLocation string = deployment().location
param agentLocation string = deployment().location
param imageBuilderLocation string = deployment().location
param imageLocation string = deployment().location
param opsLocation string = deployment().location

param logAnalyticsWorkspaceName string = take('${resourceAffix}-laws', 63)
param logAnalyticsWorkspaceRetentionInDays int = 30
param logAnalyticsWorkspaceSkuName string = 'PerGB2018'
param logAnalyticsWorkspaceCappingDailyQuotaGb int = -1

param hubTags object = {
  'envtype': envType
  'org': organization
  'workload': workload
  'component': 'hub'
}
param agentTags object = {
  'envtype': envType
  'org': organization
  'workload': workload
  'component': 'agent'
}
param imageBuilderTags object = {
  'envtype': envType
  'org': organization
  'workload': workload
  'component': 'imagebuilder'
}
param imageTags object = {
  'envtype': envType
  'org': organization
  'workload': workload
  'component': 'image'
}

param opsTags object = {
  'envtype': envType
  'org': organization
  'workload': workload
  'component': 'ops'
}


module hubResourceGroup './modules/resourceGroup.bicep' = {
  name: 'deploy-hub-rg-${nowUtc}'
  scope: subscription(hubSubscriptionId)
  params: {
    name: hubResourceGroupName
    location: hubLocation
    tags: hubTags
  }
}

module agentResourceGroup './modules/resourceGroup.bicep' = {
  name: 'deploy-agent-rg-${nowUtc}'
  scope: subscription(agentSubscriptionId)
  params: {
    name: agentResourceGroupName
    location: agentLocation
    tags: agentTags
  }
}

module imageBuilderResourceGroup './modules/resourceGroup.bicep' = {
  name: 'deploy-imagebuilder-rg-${nowUtc}'
  scope: subscription(imageBuilderubscriptionId)
  params: {
    name: imageBuilderResourceGroupName
    location: imageBuilderLocation
    tags: imageBuilderTags
  }
}
module imageResourceGroup './modules/resourceGroup.bicep' = {
  name: 'deploy-image-rg-${nowUtc}'
  scope: subscription(imageSubscriptionId)
  params: {
    name: imageResourceGroupName
    location: imageLocation
    tags: imageTags
  }
}

module opsResourceGroup './modules/resourceGroup.bicep' = {
  name: 'deploy-ops-rg-${nowUtc}'
  scope: subscription(opsSubscriptionId)
  params: {
    name: opsResourceGroupName
    location: opsLocation
    tags: opsTags
  }
}

module logAnalyticsWorkspace './modules/logAnalyticsWorkspace.bicep' = {
  name: 'deploy-laws-${nowUtc}'
  scope: resourceGroup(opsSubscriptionId, opsResourceGroupName)
  params: {
    name: logAnalyticsWorkspaceName
    location: opsLocation
    tags: opsTags

    retentionInDays: logAnalyticsWorkspaceRetentionInDays
    skuName: logAnalyticsWorkspaceSkuName
    workspaceCappingDailyQuotaGb: logAnalyticsWorkspaceCappingDailyQuotaGb
  }
  dependsOn: [
    opsResourceGroup
  ]
}





