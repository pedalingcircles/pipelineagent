targetScope = 'subscription'

param spokeName string
param spokeResourceGroupName string
param spokeVirtualNetworkName string

param hubVirtualNetworkName string
param hubVirtualNetworkResourceId string

param nowUtc string = utcNow()

module spokeNetworkPeering './virtualNetworkPeering.bicep' = {
  name: 'deploy-${spokeName}-network-peering-${nowUtc}'
  scope: resourceGroup(spokeResourceGroupName)
  params: {
    name: '${spokeVirtualNetworkName}/to-${hubVirtualNetworkName}'
    remoteVirtualNetworkResourceId: hubVirtualNetworkResourceId
  }
}
