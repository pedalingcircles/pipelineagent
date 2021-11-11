param location string
param tags object = {}
param hubVirtualNetworkName string
param bastionHostName string
param bastionHostSubnetAddressPrefix string
param bastionHostPublicIPAddressName string
param bastionHostPublicIPAddressSkuName string 
param bastionHostPublicIPAddressAllocationMethod string
param bastionHostPublicIPAddressAvailabilityZones array
param bastionHostIPConfigurationName string
param nowUtc string = utcNow()

resource hubVirtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: hubVirtualNetworkName
}

module bastionHost './bastionHost.bicep' = {
  name: 'deploy-remote-access-bastionhost-${nowUtc}'
  params: {
    name: bastionHostName
    location: location
    tags: tags

    virtualNetworkName: hubVirtualNetwork.name
    subnetAddressPrefix: bastionHostSubnetAddressPrefix
    publicIPAddressName: bastionHostPublicIPAddressName
    publicIPAddressSkuName: bastionHostPublicIPAddressSkuName
    publicIPAddressAllocationMethod: bastionHostPublicIPAddressAllocationMethod
    publicIPAddressAvailabilityZones: bastionHostPublicIPAddressAvailabilityZones
    ipConfigurationName: bastionHostIPConfigurationName
  }
}
