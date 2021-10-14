targetScope = 'subscription'

param hubResourceGroupName string
param hubVirtualNetworkName string
param imageVirtualNetworkName string
param imageVirtualNetworkResourceId string
param agentVirtualNetworkName string
param agentVirtualNetworkResourceId string
param operationsVirtualNetworkName string
param operationsVirtualNetworkResourceId string

param nowUtc string = utcNow()

module hubToImageVirtualNetworkPeering './virtualNetworkPeering.bicep' = {
  scope: resourceGroup(hubResourceGroupName)
  name: 'deploy-hubtoimage-vnet-peering-storage-${nowUtc}'
  params: {
    name: '${hubVirtualNetworkName}/to-${imageVirtualNetworkName}'
    remoteVirtualNetworkResourceId: imageVirtualNetworkResourceId
  }
}

module hubToAgentVirtualNetworkPeering './virtualNetworkPeering.bicep' = {
  scope: resourceGroup(hubResourceGroupName)
  name: 'deploy-hubtoagent-vnet-peering-storage-${nowUtc}'
  params: {
    name: '${hubVirtualNetworkName}/to-${agentVirtualNetworkName}'
    remoteVirtualNetworkResourceId: agentVirtualNetworkResourceId
  }
}

module hubToOperationsVirtualNetworkPeering './virtualNetworkPeering.bicep' = {
  scope: resourceGroup(hubResourceGroupName)
  name: 'deploy-hubtooperations-vnet-peering-storage-${nowUtc}'
  params: {
    name: '${hubVirtualNetworkName}/to-${operationsVirtualNetworkName}'
    remoteVirtualNetworkResourceId: operationsVirtualNetworkResourceId
  }
}


