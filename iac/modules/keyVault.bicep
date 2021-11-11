param name string
param location string
param tags object = {}
param enabledForDeployment bool = true
param enabledForDiskEncryption bool = true
param enabledForTemplateDeployment bool = true
param enableRbacAuthorization bool = false
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
param softDeleteRetentionInDays int = 7
param tenantId string
param sku object = {
  family: 'A'
  name: 'Premium'
}

param ignoreMissingVnetServiceEndpoint bool = false
param existingVnetName string 
param existingSubnetName string

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
  name: existingVnetName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: existingSubnetName
}

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    accessPolicies: keyVaultAccessPolicies
    enabledForDeployment: enabledForDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enableRbacAuthorization: enableRbacAuthorization  // This is a preview feature and may be used in the future (replaces access policies)
    networkAcls: {
      bypass: bypass
      defaultAction: defaultAction
      ipRules: ipRules
      virtualNetworkRules: [
        {
          id: subnet.id
          ignoreMissingVnetServiceEndpoint: ignoreMissingVnetServiceEndpoint
        }
      ]
    }
    sku: sku
    softDeleteRetentionInDays: softDeleteRetentionInDays
    tenantId: tenantId
  }
}

output id string = keyVault.id
