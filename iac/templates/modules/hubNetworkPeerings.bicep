targetScope = 'subscription'

param hubResourceGroupName string
param hubVirtualNetworkName string
param imageVirtualNetworkName string
param imageVirtualNetworkResourceId string
param agentVirtualNetworkName string
param agentVirtualNetworkResourceId string
param operationsVirtualNetworkName string
param operationsVirtualNetworkResourceId string

module hubToImageVirtualNetworkPeering './virtualNetworkPeering.bicep' = {
  scope: resourceGroup(hubResourceGroupName)
  name: 'hubToImageVirtualNetworkPeering'
  params: {
    name: '${hubVirtualNetworkName}/to-${imageVirtualNetworkName}'
    remoteVirtualNetworkResourceId: imageVirtualNetworkResourceId
  }
}

module hubToAgentVirtualNetworkPeering './virtualNetworkPeering.bicep' = {
  scope: resourceGroup(hubResourceGroupName)
  name: 'hubToAgentVirtualNetworkPeering'
  params: {
    name: '${hubVirtualNetworkName}/to-${agentVirtualNetworkName}'
    remoteVirtualNetworkResourceId: agentVirtualNetworkResourceId
  }
}

module hubToOperationsVirtualNetworkPeering './virtualNetworkPeering.bicep' = {
  scope: resourceGroup(hubResourceGroupName)
  name: 'hubToOperationsVirtualNetworkPeering'
  params: {
    name: '${hubVirtualNetworkName}/to-${operationsVirtualNetworkName}'
    remoteVirtualNetworkResourceId: operationsVirtualNetworkResourceId
  }
}


