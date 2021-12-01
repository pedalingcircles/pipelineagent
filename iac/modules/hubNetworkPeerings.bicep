param hubVirtualNetworkName string
param spokes array
param nowUtc string = utcNow()

module hubToSpokePeering './virtualNetworkPeering.bicep' = [ for spoke in spokes: {
  name: 'hub-to-${spoke.type}-vnet-peering-${nowUtc}'
  params: {
    name: '${hubVirtualNetworkName}/to-${spoke.virtualNetworkName}'
    remoteVirtualNetworkResourceId: spoke.virtualNetworkResourceId
  }
}]
