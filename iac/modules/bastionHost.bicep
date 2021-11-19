param name string
param location string
param tags object = {}
param virtualNetworkName string
param subnetName string
param ipConfigurationName string
param publicIPAddressName string
param publicIPAddressSkuName string
param publicIPAddressAllocationMethod string
param publicIPAddressAvailabilityZones array

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: virtualNetworkName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: subnetName
  parent: vnet
}

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: publicIPAddressName
  location: location
  tags: tags
  sku: {
    name: publicIPAddressSkuName
  }
  properties: {
    publicIPAllocationMethod: publicIPAddressAllocationMethod
  }
  zones: publicIPAddressAvailabilityZones
}

resource bastionHost 'Microsoft.Network/bastionHosts@2021-02-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: ipConfigurationName
        properties: {
          subnet: {
            id: subnet.id
          }
          publicIPAddress: {
            id: publicIPAddress.id
          }
        }
      }
    ]
  }
}
