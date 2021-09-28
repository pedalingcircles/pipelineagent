
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

resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    accessPolicies: keyVaultAccessPolicies
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
    enablePurgeProtection: true
    enableRbacAuthorization: false  // This is a preview feature and may be used in the future (replaces access policies)
    enableSoftDelete: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: []
      virtualNetworkRules: [
        {
          id: '/subscriptions/subid/resourceGroups/rg1/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/subnet1'
          ignoreMissingVnetServiceEndpoint: true
        }
      ]
    }
    publicNetworkAccess: 'disabled'
    sku: {
      family: 'A'
      name: 'premium'
    }
    softDeleteRetentionInDays: 7
    tenantId: tenantId
  }
}

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

resource networkSecurityGroupVmAgentResource 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  location: location
  name: vmAgentNsgName
  properties: {
    securityRules: []
  }
}

/*
Azure Bastion NSG Rules
Bastion requires specific rules in order to 
apply an NSG against the subnet
see: https://docs.microsoft.com/en-us/azure/bastion/bastion-nsg#apply
*/ 
resource networkSecurityGroupBastionResource 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  location: location
  name: bastionNsgName
  properties: {
    securityRules: [
      {
        name: 'AllowHttpsInbound'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: '*'
          destinationAddressPrefixes: []
          destinationPortRange: '443'
          destinationPortRanges: []
          direction: 'Inbound'
          priority: 120
          protocol: 'Tcp'
          sourceAddressPrefix: 'Internet'
          sourceAddressPrefixes: []
          sourcePortRange: '*'
          sourcePortRanges: []
        }
      }
      {
        name: 'AllowGatewayManagerInbound'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: '*'
          destinationAddressPrefixes: []
          destinationPortRange: '443'
          destinationPortRanges: []
          direction: 'Inbound'
          priority: 130
          protocol: 'Tcp'
          sourceAddressPrefix: 'GatewayManager'
          sourceAddressPrefixes: []
          sourcePortRange: '*'
          sourcePortRanges: []
        }
      }
      {
        name: 'AllowAzureLoadBalancerInbound'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: '*'
          destinationAddressPrefixes: []
          destinationPortRange: '443'
          destinationPortRanges: []
          direction: 'Inbound'
          priority: 140
          protocol: 'Tcp'
          sourceAddressPrefix: 'AzureLoadBalancer'
          sourceAddressPrefixes: []
          sourcePortRange: '*'
          sourcePortRanges: []
        }
      }
      {
        name: 'AllowBastionHostCommunication'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: '*'
          destinationAddressPrefixes: []
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          direction: 'Inbound'
          priority: 150
          protocol: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          sourceAddressPrefixes: []
          sourcePortRange: '*'
          sourcePortRanges: []
        }
      }
      {
        name: 'AllowSshRdpOutbound'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefixes: []
          destinationPortRanges: [
            '22'
            '3389'
          ]
          direction: 'Outbound'
          priority: 100
          protocol: '*'
          sourceAddressPrefix: '*'
          sourceAddressPrefixes: []
          sourcePortRange: '*'
          sourcePortRanges: []
        }
      }
      {
        name: 'AllowAzureCloudOutbound'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: 'AzureCloud'
          destinationAddressPrefixes: []
          destinationPortRange: '443'
          destinationPortRanges: []
          direction: 'Outbound'
          priority: 110
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourceAddressPrefixes: []
          sourcePortRange: '*'
          sourcePortRanges: []
        }
      }
      {
        name: 'AllowBastionCommunication'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefixes: []
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          direction: 'Outbound'
          priority: 120
          protocol: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          sourceAddressPrefixes: []
          sourcePortRange: '*'
          sourcePortRanges: []
        }
      }
      {
        name: 'AllowGetSessionInformation'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: 'Internet'
          destinationAddressPrefixes: []
          destinationPortRange: '80'
          destinationPortRanges: []
          direction: 'Outbound'
          priority: 130
          protocol: '*'
          sourceAddressPrefix: '*'
          sourceAddressPrefixes: []
          sourcePortRange: '*'
          sourcePortRanges: []
        }
      }
    ]
  }
}

resource bastionPublicIpResource 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  location: location
  name: bastionPipName
  properties: {
    idleTimeoutInMinutes: 4
    //ipAddress: '13.68.75.34'
    ipTags: []
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2020-11-01' = {
  location: location
  name: bastionHostName
  properties: {
    dnsName: 'bst-4565b6a8-d4e4-49c8-8ce9-91520fdfea2f.bastion.azure.com'
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: bastionPublicIpResource.id
          }
          subnet: {
            id: '${vNet.id}/subnets/${bastionSubnetName}'
          }
        }
      }
    ]
  }
}


// output bastion public ip

