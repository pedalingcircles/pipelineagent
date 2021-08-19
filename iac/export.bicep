param bastionHosts_bastion_agent_name string = 'bastion-agent'
param virtualNetworks_vnet_agents_name string = 'vnet-agents'
param publicIPAddresses_pip_bastion_name string = 'pip-bastion'
param networkSecurityGroups_nsg_bastion_name string = 'nsg-bastion'
param networkSecurityGroups_nsg_vmagent_name string = 'nsg-vmagent'
param virtualMachines_vm_agent_mijohns_001_name string = 'vm-agent-mijohns-001'
param sshPublicKeys_vm_agent_mijohns_001_key_name string = 'vm-agent-mijohns-001_key'
param networkInterfaces_vm_agent_mijohns_001312_name string = 'vm-agent-mijohns-001312'
param galleries_sig_agentimages_externalid string = '/subscriptions/cbadc96b-2923-4459-bb2d-b237af7f84d6/resourceGroups/rg-mijohns-images-sbx-eastus2-001/providers/Microsoft.Compute/galleries/sig.agentimages'

resource sshPublicKeys_vm_agent_mijohns_001_key_name_resource 'Microsoft.Compute/sshPublicKeys@2021-03-01' = {
  name: sshPublicKeys_vm_agent_mijohns_001_key_name
  location: 'eastus2'
  tags: {
    foo: 'bar'
    bang: 'buzz'
  }
  properties: {
    publicKey: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDU7umcmBF5A5J14ov8vRMPG3gs\r\n0RA8EH+SZ1LB3zhkAaHZZ4p+FcTozl/P1slqBft0FQF8p3fAOHbxO2AwjcZTiCDA\r\n1nq5Nw+UlTzZ+ZNo82CY3GNUofKwjrKNrrrd5RSOSPzrxYc2X658w2MAn+bnomhT\r\n81inURttWKZ3ApZ2a7+OgZVpYQ3Stedymq/Gyo/TVHXZQZBljBwJxc/D5DgZq2xi\r\npknWEcpYx6q/MQs9JKsFi0h1beIjap6M9/X+sEeRTbsybU6XAaPOlZhWLBY97BzV\r\nQBjLh8U6ZJzcHpuETpQTSHGtdDKQpbtFsl9Gfj565z6Agqka41DS1ydYM9be13j+\r\niHLkBuXMqRP78kN3peqlYxhg5uMnlHLb3TimWxW3Sd/qQspuY0/vScG4oPT6vm+a\r\nAzTG3k1tGlsZg3BkFD5oDbWJGAwfuz/T8QvMREwxK3OufuyuiPcuS/QSbLkgmyXH\r\nj8kbTxOzY1tCyRl2lX9t7oWCD7WAmI8UvZKzY/k= generated-by-azure\r\n'
  }
}

resource networkSecurityGroups_nsg_bastion_name_resource 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: networkSecurityGroups_nsg_bastion_name
  location: 'eastus2'
  properties: {
    securityRules: [
      {
        name: 'AllowHttpsInbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'AllowGatewayManagerInbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'GatewayManager'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 130
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'AllowAzureLoadBalancerInbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 140
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'AllowBastionHostCommunication'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 150
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'AllowSshRdpOutbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: [
            '22'
            '3389'
          ]
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'AllowAzureCloudOutbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'AzureCloud'
          access: 'Allow'
          priority: 110
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'AllowBastionCommunication'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 120
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'AllowGetSessionInformation'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Internet'
          access: 'Allow'
          priority: 130
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
}

resource networkSecurityGroups_nsg_vmagent_name_resource 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: networkSecurityGroups_nsg_vmagent_name
  location: 'eastus2'
  properties: {
    securityRules: []
  }
}

resource publicIPAddresses_pip_bastion_name_resource 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: publicIPAddresses_pip_bastion_name
  location: 'eastus2'
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    ipAddress: '20.65.34.144'
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}

resource virtualMachines_vm_agent_mijohns_001_name_resource 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: virtualMachines_vm_agent_mijohns_001_name
  location: 'eastus2'
  tags: {
    foo: 'bar'
    bang: 'buzz'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D4s_v4'
    }
    storageProfile: {
      imageReference: {
        id: '${galleries_sig_agentimages_externalid}/images/ubuntu2004'
      }
      osDisk: {
        osType: 'Linux'
        name: '${virtualMachines_vm_agent_mijohns_001_name}_OsDisk_1_9b2659df1daa4035ad8833c2eb47bd40'
        createOption: 'FromImage'
        caching: 'None'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
          id: resourceId('Microsoft.Compute/disks', '${virtualMachines_vm_agent_mijohns_001_name}_OsDisk_1_9b2659df1daa4035ad8833c2eb47bd40')
        }
        diskSizeGB: 86
      }
      dataDisks: []
    }
    osProfile: {
      computerName: virtualMachines_vm_agent_mijohns_001_name
      adminUsername: 'azureuser'
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/azureuser/.ssh/authorized_keys'
              keyData: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDU7umcmBF5A5J14ov8vRMPG3gs\r\n0RA8EH+SZ1LB3zhkAaHZZ4p+FcTozl/P1slqBft0FQF8p3fAOHbxO2AwjcZTiCDA\r\n1nq5Nw+UlTzZ+ZNo82CY3GNUofKwjrKNrrrd5RSOSPzrxYc2X658w2MAn+bnomhT\r\n81inURttWKZ3ApZ2a7+OgZVpYQ3Stedymq/Gyo/TVHXZQZBljBwJxc/D5DgZq2xi\r\npknWEcpYx6q/MQs9JKsFi0h1beIjap6M9/X+sEeRTbsybU6XAaPOlZhWLBY97BzV\r\nQBjLh8U6ZJzcHpuETpQTSHGtdDKQpbtFsl9Gfj565z6Agqka41DS1ydYM9be13j+\r\niHLkBuXMqRP78kN3peqlYxhg5uMnlHLb3TimWxW3Sd/qQspuY0/vScG4oPT6vm+a\r\nAzTG3k1tGlsZg3BkFD5oDbWJGAwfuz/T8QvMREwxK3OufuyuiPcuS/QSbLkgmyXH\r\nj8kbTxOzY1tCyRl2lX9t7oWCD7WAmI8UvZKzY/k= generated-by-azure\r\n'
            }
          ]
        }
        provisionVMAgent: true
        patchSettings: {
          patchMode: 'ImageDefault'
          assessmentMode: 'ImageDefault'
        }
      }
      secrets: []
      allowExtensionOperations: true
      requireGuestProvisionSignal: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaces_vm_agent_mijohns_001312_name_resource.id
        }
      ]
    }
  }
}

resource networkInterfaces_vm_agent_mijohns_001312_name_resource 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: networkInterfaces_vm_agent_mijohns_001312_name
  location: 'eastus2'
  tags: {
    foo: 'bar'
    bang: 'buzz'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: '10.0.1.4'
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: virtualNetworks_vnet_agents_name_snet_vmagent.id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: false
    enableIPForwarding: false
  }
}

resource networkSecurityGroups_nsg_bastion_name_AllowAzureCloudOutbound 'Microsoft.Network/networkSecurityGroups/securityRules@2020-11-01' = {
  parent: networkSecurityGroups_nsg_bastion_name_resource
  name: 'AllowAzureCloudOutbound'
  properties: {
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '443'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: 'AzureCloud'
    access: 'Allow'
    priority: 110
    direction: 'Outbound'
    sourcePortRanges: []
    destinationPortRanges: []
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
}

resource networkSecurityGroups_nsg_bastion_name_AllowAzureLoadBalancerInbound 'Microsoft.Network/networkSecurityGroups/securityRules@2020-11-01' = {
  parent: networkSecurityGroups_nsg_bastion_name_resource
  name: 'AllowAzureLoadBalancerInbound'
  properties: {
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '443'
    sourceAddressPrefix: 'AzureLoadBalancer'
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 140
    direction: 'Inbound'
    sourcePortRanges: []
    destinationPortRanges: []
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
}

resource networkSecurityGroups_nsg_bastion_name_AllowBastionCommunication 'Microsoft.Network/networkSecurityGroups/securityRules@2020-11-01' = {
  parent: networkSecurityGroups_nsg_bastion_name_resource
  name: 'AllowBastionCommunication'
  properties: {
    protocol: '*'
    sourcePortRange: '*'
    sourceAddressPrefix: 'VirtualNetwork'
    destinationAddressPrefix: 'VirtualNetwork'
    access: 'Allow'
    priority: 120
    direction: 'Outbound'
    sourcePortRanges: []
    destinationPortRanges: [
      '8080'
      '5701'
    ]
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
}

resource networkSecurityGroups_nsg_bastion_name_AllowBastionHostCommunication 'Microsoft.Network/networkSecurityGroups/securityRules@2020-11-01' = {
  parent: networkSecurityGroups_nsg_bastion_name_resource
  name: 'AllowBastionHostCommunication'
  properties: {
    protocol: '*'
    sourcePortRange: '*'
    sourceAddressPrefix: 'VirtualNetwork'
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 150
    direction: 'Inbound'
    sourcePortRanges: []
    destinationPortRanges: [
      '8080'
      '5701'
    ]
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
}

resource networkSecurityGroups_nsg_bastion_name_AllowGatewayManagerInbound 'Microsoft.Network/networkSecurityGroups/securityRules@2020-11-01' = {
  parent: networkSecurityGroups_nsg_bastion_name_resource
  name: 'AllowGatewayManagerInbound'
  properties: {
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '443'
    sourceAddressPrefix: 'GatewayManager'
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 130
    direction: 'Inbound'
    sourcePortRanges: []
    destinationPortRanges: []
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
}

resource networkSecurityGroups_nsg_bastion_name_AllowGetSessionInformation 'Microsoft.Network/networkSecurityGroups/securityRules@2020-11-01' = {
  parent: networkSecurityGroups_nsg_bastion_name_resource
  name: 'AllowGetSessionInformation'
  properties: {
    protocol: '*'
    sourcePortRange: '*'
    destinationPortRange: '80'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: 'Internet'
    access: 'Allow'
    priority: 130
    direction: 'Outbound'
    sourcePortRanges: []
    destinationPortRanges: []
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
}

resource networkSecurityGroups_nsg_bastion_name_AllowHttpsInbound 'Microsoft.Network/networkSecurityGroups/securityRules@2020-11-01' = {
  parent: networkSecurityGroups_nsg_bastion_name_resource
  name: 'AllowHttpsInbound'
  properties: {
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '443'
    sourceAddressPrefix: 'Internet'
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 120
    direction: 'Inbound'
    sourcePortRanges: []
    destinationPortRanges: []
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
}

resource networkSecurityGroups_nsg_bastion_name_AllowSshRdpOutbound 'Microsoft.Network/networkSecurityGroups/securityRules@2020-11-01' = {
  parent: networkSecurityGroups_nsg_bastion_name_resource
  name: 'AllowSshRdpOutbound'
  properties: {
    protocol: '*'
    sourcePortRange: '*'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: 'VirtualNetwork'
    access: 'Allow'
    priority: 100
    direction: 'Outbound'
    sourcePortRanges: []
    destinationPortRanges: [
      '22'
      '3389'
    ]
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
}

resource bastionHosts_bastion_agent_name_resource 'Microsoft.Network/bastionHosts@2020-11-01' = {
  name: bastionHosts_bastion_agent_name
  location: 'eastus2'
  sku: {
    name: 'Basic'
  }
  properties: {
    dnsName: 'bst-a5f87594-6e7a-4615-a45b-3e0900162f0e.bastion.azure.com'
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddresses_pip_bastion_name_resource.id
          }
          subnet: {
            id: virtualNetworks_vnet_agents_name_AzureBastionSubnet.id
          }
        }
      }
    ]
  }
}

resource virtualNetworks_vnet_agents_name_resource 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: virtualNetworks_vnet_agents_name
  location: 'eastus2'
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-containers'
        properties: {
          addressPrefix: '10.0.0.0/24'
          networkSecurityGroup: {
            id: networkSecurityGroups_nsg_vmagent_name_resource.id
          }
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'snet-vmagent'
        properties: {
          addressPrefix: '10.0.1.0/24'
          networkSecurityGroup: {
            id: networkSecurityGroups_nsg_vmagent_name_resource.id
          }
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.0.2.0/24'
          networkSecurityGroup: {
            id: networkSecurityGroups_nsg_bastion_name_resource.id
          }
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

resource virtualNetworks_vnet_agents_name_AzureBastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  parent: virtualNetworks_vnet_agents_name_resource
  name: 'AzureBastionSubnet'
  properties: {
    addressPrefix: '10.0.2.0/24'
    networkSecurityGroup: {
      id: networkSecurityGroups_nsg_bastion_name_resource.id
    }
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource virtualNetworks_vnet_agents_name_snet_containers 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  parent: virtualNetworks_vnet_agents_name_resource
  name: 'snet-containers'
  properties: {
    addressPrefix: '10.0.0.0/24'
    networkSecurityGroup: {
      id: networkSecurityGroups_nsg_vmagent_name_resource.id
    }
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource virtualNetworks_vnet_agents_name_snet_vmagent 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  parent: virtualNetworks_vnet_agents_name_resource
  name: 'snet-vmagent'
  properties: {
    addressPrefix: '10.0.1.0/24'
    networkSecurityGroup: {
      id: networkSecurityGroups_nsg_vmagent_name_resource.id
    }
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}