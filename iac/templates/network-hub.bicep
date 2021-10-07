
@description('Bastion host name to support the CI/CD (ADO) Agents.')
@minLength(1)
@maxLength(80)
param bastionHostName string

@description('Network Security Group for the bastion host.')
@minLength(1)
@maxLength(80)
param bastionNsgName string

@minLength(36)
@maxLength(36)
@description('The Azure Active Directory tenant ID that should be used for authenticating requests to the key vault.')
param tenantId string

@description('Public IP name for the bastion host.')
param bastionPipName string

@description('The set of key value pairs of tags to apply to resources.')
param tags object = {}

@description('The key vault name.')
param keyVaultName string

@description('The access policies for the key vault.')
param keyVaultAccessPolicies array

@description('Network Security Group for the VM Agents.')
@minLength(1)
@maxLength(80)
param vmAgentNsgName string

@description('Virtual Network settings.')
param vNetSettings object

@description('Location for agent and related resources. This will likely be the same region where the ADO organization is located.')
param location string = resourceGroup().location

// Azure Bastion can only be created in subnet with name 'AzureBastionSubnet'.
var bastionSubnetName = 'AzureBastionSubnet'


resource vNet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: vNetSettings.name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vNetSettings.addressPrefixes[0].addressPrefix
      ]
    }
    enableDdosProtection: false
    subnets: [
      {
        name: 'snet-containers'
        properties: {
          addressPrefix: vNetSettings.subnets[0].addressPrefix
          delegations: []
          networkSecurityGroup: {
            id: networkSecurityGroupVmAgentResource.id
          }
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'snet-vmagent'
        properties: {
          addressPrefix: vNetSettings.subnets[1].addressPrefix
          delegations: []
          networkSecurityGroup: {
            id: networkSecurityGroupVmAgentResource.id
          }
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: bastionSubnetName
        properties: {
          addressPrefix: vNetSettings.subnets[2].addressPrefix
          delegations: []
          networkSecurityGroup: {
            id: networkSecurityGroupBastionResource.id
          }
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    virtualNetworkPeerings: []
  }
}
