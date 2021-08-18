@description('The storage account name used by Packer to store VM images.')
@minLength(3)
@maxLength(24)
param storageAccountName string

@description('The Shared Image Gallery name used to store VM images used for self-hosted ADO agents.')
@minLength(1)
@maxLength(80)
param sharedImageGalleryName string

@description('Virtual Network settings.')
param vNetSettings object = {
  name: 'vnet'
  addressPrefixes: [
    {
      name: 'firstPrefix'
      addressPrefix: '10.0.0.0/16'
    }
  ]
  subnets: [
    {
      addressPrefix: '10.0.0.0/24'
    }
  ]
}

@description('Location for images and related resources. This will likely be the same region where the ADO org is located.')
param location string = resourceGroup().location

var packerSubnetName = 'snet-packer'

resource vNet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: vNetSettings.name
  location: location
  tags: {
    envtype: 'sbx'
    envuse: 'packer'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        vNetSettings.addressPrefixes[0].addressPrefix
      ]
    }
    subnets: [
      {
        name: packerSubnetName
        properties: {
          addressPrefix: vNetSettings.subnets[0].addressPrefix
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
              locations: [
                location
              ]
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  tags: {
    envtype: 'sbx'
    envuse: 'packer'
  }
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
    networkAcls: {
      resourceAccessRules: []
      bypass: 'AzureServices'
      virtualNetworkRules: [
        {
          id: '${vNet.id}/subnets/${packerSubnetName}'
          action: 'Allow'
          state: 'Succeeded'
        }
      ]
      ipRules: []
      defaultAction: 'Deny'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

resource sharedImageGallery 'Microsoft.Compute/galleries@2020-09-30' = {
  name: sharedImageGalleryName
  location: location
  tags: {
    envtype: 'sbx'
    envuse: 'packer'
  }
  properties: {
    description: 'Shared Image Gallery used to store virtual machine images used for creating self-hosted Azure DevOps Agents.'
  }
}