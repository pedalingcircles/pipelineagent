param name string
param location string
param tags object = {}
param enabledForDeployment bool = true
param enabledForDiskEncryption bool = false
param enabledForTemplateDeployment bool = true
param enablePurgeProtection bool = true
param enableRbacAuthorization bool = false
param enableSoftDelete bool = true

@description('The access policies for the key vault.')
param keyVaultAccessPolicies array

@allowed([
  'Allow'
  'Deny'
])
param defaultAction string = 'Deny'

@allowed([
  'AzureServices'
  'None'
])
param bypass string = 'AzureServices'
param ipRules array = []

@allowed([
  'disabled'
  'enabled'
])
param publicNetworkAccess string = 'enabled'

param tenentId string
param softDeleteRetentionInDays int = 7
param sku object = {
  family: 'A'
  name: 'premium'
}

param ignoreMissingVnetServiceEndpoint bool = true
param existingVnetName string 
param existingSubnetName string

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
  name: existingVnetName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: existingSubnetName
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: name
  location: location
  tags: tags
  properties: {
    accessPolicies: keyVaultAccessPolicies
    enabledForDeployment: enabledForDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enablePurgeProtection: enablePurgeProtection
    enableRbacAuthorization: enableRbacAuthorization  // This is a preview feature and may be used in the future (replaces access policies)
    enableSoftDelete: enableSoftDelete
    networkAcls: {
      bypass: bypass
      defaultAction: defaultAction
      ipRules: ipRules
      virtualNetworkRules: [
        {
          id: '${vnet.id}/subnets/${subnet.name}'
          ignoreMissingVnetServiceEndpoint: ignoreMissingVnetServiceEndpoint
        }
      ]
    }
    publicNetworkAccess: publicNetworkAccess
    sku: sku
    softDeleteRetentionInDays: softDeleteRetentionInDays
    tenantId: tenentId
  }
}

output id string = keyVault.id
