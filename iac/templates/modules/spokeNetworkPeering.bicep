targetScope = 'subscription'

param spokeResourceGroupName string
param spokeVirtualNetworkName string

param hubVirtualNetworkName string
param hubVirtualNetworkResourceId string

param nowUtc string = utcNow()
module spokeNetworkPeering './virtualNetworkPeering.bicep' = {
  scope: resourceGroup(spokeResourceGroupName)
  name: 'deploy-spoke-network-peering-${nowUtc}'
  params: {
    name: '${spokeVirtualNetworkName}/to-${hubVirtualNetworkName}'
    remoteVirtualNetworkResourceId: hubVirtualNetworkResourceId
  }
}
