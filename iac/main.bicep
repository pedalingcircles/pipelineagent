
param vnetName string = 'vnet-adoagent-sbx-eastus2'
param registryName string = ''

resource agentVnet 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: vnetName
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
      '10.0.0.0/16'
    ]
    }
    subnets: [
      {
        name: 'Bastion-Subnet'
        properties: {
          addressPrefix: '10.0.0.0/26'
        }
      }
      {
        name: 'ACI-Subnet'
        properties: {
          addressPrefix: '10.0.1.0/26'
        }
      }
    ]
  }
}

resource agentContainerRegistry 'Microsoft.ContainerRegistry/registries@2020-11-01-preview' = {
  name: registryName
  location: resourceGroup().location
  sku: {
    name: 'Premium'
  }
  properties: {
    adminUserEnabled: false
    networkRuleSet: {
      defaultAction: 'Allow'
      virtualNetworkRules: []
      ipRules: []
    }
    policies: {
      quarantinePolicy: {
        status: 'disabled'
      }
      trustPolicy: {
        type: 'Notary'
        status: 'disabled'
      }
      retentionPolicy: {
        days: 7
        status: 'disabled'
      }
    }
    encryption: {
      status: 'disabled'
    }
    dataEndpointEnabled: false
    publicNetworkAccess: 'Disabled'
    networkRuleBypassOptions: 'AzureServices'
    zoneRedundancy: 'Disabled'
    anonymousPullEnabled: false
  }
}

