
param storageAccountName string
param sharedGalleryName string
param containerRegistryName string
param vnetName string
param vnetAddressPrefix string = '172.19.0.0/24'


param vmPrefix string
param location string = resourceGroup().location


resource vnet 'Microsoft.Network/virtualNetworks@2020-07-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'snet-vmagent'  
        properties: {
          addressPrefix: '172.19.0.0/24'
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


resource sig_contoso_agent 'Microsoft.Compute/galleries@2020-09-30' = {
  name: 'sig.contoso.agent'
  location: 'eastus2'
  properties: {
    identifier: {}
  }
}

resource acrcontosoadoagent 'Microsoft.ContainerRegistry/registries@2020-11-01-preview' = {
  name: 'acrcontosoadoagent'
  location: 'eastus2'
  sku: {
    name: 'Premium'
    tier: 'Premium'
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

resource pe_agent_nic_ec216107_da29_4c40_be64_39e72ba7873d 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: 'pe-agent.nic.ec216107-da29-4c40-be64-39e72ba7873d'
  location: 'eastus2'
  properties: {
    ipConfigurations: [
      {
        name: 'registry-registry_data_eastus2.privateEndpoint'
        properties: {
          privateIPAddress: '10.0.0.5'
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: '/subscriptions/cbadc96b-2923-4459-bb2d-b237af7f84d6/resourceGroups/mijohns-deleteme-vmtest/providers/Microsoft.Network/virtualNetworks/mijohnsdeletemevmtestVNET/subnets/mijohnsdeletemevmtestSubnet'
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
      {
        name: 'registry-registry.privateEndpoint'
        properties: {
          privateIPAddress: '10.0.0.6'
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: '/subscriptions/cbadc96b-2923-4459-bb2d-b237af7f84d6/resourceGroups/mijohns-deleteme-vmtest/providers/Microsoft.Network/virtualNetworks/mijohnsdeletemevmtestVNET/subnets/mijohnsdeletemevmtestSubnet'
          }
          primary: false
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



resource stcontosoagentimages 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: 'stcontosoagentimages'
  location: 'eastus2'
  sku: {
    name: 'Standard_RAGRS'
    tier: 'Standard'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
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

resource packer_Ubuntu1604_20210504_2 'Microsoft.Compute/disks@2020-09-30' = {
  name: 'packer-Ubuntu1604-20210504.2'
  location: 'eastus2'
  sku: {
    name: 'Premium_LRS'
    tier: 'Premium'
  }
  properties: {
    creationData: {
      createOption: 'Import'
      storageAccountId: stcontosoagentimages.id
      sourceUri: 'https://stcontosoagentimages.blob.core.windows.net/system/Microsoft.Compute/Images/ci-packerimage-ubuntu1604-20210504-1/packer-osDisk.4601eb13-476e-4ec2-b460-f3ec8f3391ef.vhd'
    }
    diskSizeGB: 86
    diskIOPSReadWrite: 500
    diskMBpsReadWrite: 100
    encryption: {
      type: 'EncryptionAtRestWithPlatformKey'
    }
    diskState: 'Unattached'
    networkAccessPolicy: 'AllowAll'
    tier: 'P10'
  }
}

resource sig_contoso_agent_Ubuntu1604 'Microsoft.Compute/galleries/images@2020-09-30' = {
  parent: sig_contoso_agent
  name: 'Ubuntu1604'
  location: 'eastus2'
  properties: {
    hyperVGeneration: 'V1'
    osType: 'Linux'
    osState: 'Generalized'
    identifier: {
      publisher: 'JPS'
      offer: 'AgentPoolImage'
      sku: 'Ubuntu1604'
    }
  }
}

resource sig_contoso_agent_Ubuntu2004 'Microsoft.Compute/galleries/images@2020-09-30' = {
  parent: sig_contoso_agent
  name: 'Ubuntu2004'
  location: 'eastus2'
  properties: {
    hyperVGeneration: 'V1'
    osType: 'Linux'
    osState: 'Generalized'
    identifier: {
      publisher: 'JPS'
      offer: 'AgentPoolImage'
      sku: 'Baseline'
    }
  }
}

resource sig_contoso_agent_Windows2019 'Microsoft.Compute/galleries/images@2020-09-30' = {
  parent: sig_contoso_agent
  name: 'Windows2019'
  location: 'eastus2'
  properties: {
    hyperVGeneration: 'V1'
    osType: 'Windows'
    osState: 'Generalized'
    identifier: {
      publisher: 'JPS'
      offer: 'AgentPoolImage'
      sku: 'Windows2019'
    }
  }
}

resource Microsoft_Compute_images_packer_Ubuntu1604_20210504_2 'Microsoft.Compute/images@2021-03-01' = {
  name: 'packer-Ubuntu1604-20210504.2'
  location: 'eastus2'
  properties: {
    storageProfile: {
      osDisk: {
        osType: 'Linux'
        osState: 'Generalized'
        diskSizeGB: 86
        managedDisk: {
          id: packer_Ubuntu1604_20210504_2.id
        }
        caching: 'None'
        storageAccountType: 'Standard_LRS'
      }
      dataDisks: []
    }
    hyperVGeneration: 'V1'
  }
}

resource acrcontosoadoagent_repositories_admin 'Microsoft.ContainerRegistry/registries/scopeMaps@2020-11-01-preview' = {
  parent: acrcontosoadoagent
  name: '_repositories_admin'
  properties: {
    description: 'Can perform all read, write and delete operations on the registry'
    actions: [
      'repositories/*/metadata/read'
      'repositories/*/metadata/write'
      'repositories/*/content/read'
      'repositories/*/content/write'
      'repositories/*/content/delete'
    ]
  }
}

resource acrcontosoadoagent_repositories_pull 'Microsoft.ContainerRegistry/registries/scopeMaps@2020-11-01-preview' = {
  parent: acrcontosoadoagent
  name: '_repositories_pull'
  properties: {
    description: 'Can pull any repository of the registry'
    actions: [
      'repositories/*/content/read'
    ]
  }
}

resource acrcontosoadoagent_repositories_push 'Microsoft.ContainerRegistry/registries/scopeMaps@2020-11-01-preview' = {
  parent: acrcontosoadoagent
  name: '_repositories_push'
  properties: {
    description: 'Can push to any repository of the registry'
    actions: [
      'repositories/*/content/read'
      'repositories/*/content/write'
    ]
  }
}

resource pe_agent 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: 'pe-agent'
  location: 'eastus2'
  properties: {
    privateLinkServiceConnections: [
      {
        name: 'pe-agent'
        properties: {
          privateLinkServiceId: acrcontosoadoagent.id
          groupIds: [
            'registry'
          ]
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Auto-Approved'
            actionsRequired: 'None'
          }
        }
      }
    ]
    manualPrivateLinkServiceConnections: []
    subnet: {
      id: '/subscriptions/cbadc96b-2923-4459-bb2d-b237af7f84d6/resourceGroups/mijohns-deleteme-vmtest/providers/Microsoft.Network/virtualNetworks/mijohnsdeletemevmtestVNET/subnets/mijohnsdeletemevmtestSubnet'
    }
    customDnsConfigs: []
  }
}

resource pe_agent_default 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-11-01' = {
  parent: pe_agent
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-azurecr-io'
        properties: {
          privateDnsZoneId: '/subscriptions/cbadc96b-2923-4459-bb2d-b237af7f84d6/resourceGroups/mijohns-deleteme-vmtest/providers/Microsoft.Network/privateDnsZones/privatelink.azurecr.io'
        }
      }
    ]
  }
}

resource vnet_agent_sbx_eastus2_01_snet_acr 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  parent: vnet_agent_sbx_eastus2_01
  name: 'snet-acr'
  properties: {
    addressPrefix: '172.19.0.0/24'
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource stcontosoagentimages_default 'Microsoft.Storage/storageAccounts/blobServices@2021-04-01' = {
  parent: stcontosoagentimages
  name: 'default'
  sku: {
    name: 'Standard_RAGRS'
    tier: 'Standard'
  }
  properties: {
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      enabled: false
    }
  }
}

resource Microsoft_Storage_storageAccounts_fileServices_stcontosoagentimages_default 'Microsoft.Storage/storageAccounts/fileServices@2021-04-01' = {
  parent: stcontosoagentimages
  name: 'default'
  sku: {
    name: 'Standard_RAGRS'
    tier: 'Standard'
  }
  properties: {
    protocolSettings: {
      smb: {}
    }
    cors: {
      corsRules: []
    }
    shareDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

resource Microsoft_Storage_storageAccounts_queueServices_stcontosoagentimages_default 'Microsoft.Storage/storageAccounts/queueServices@2021-04-01' = {
  parent: stcontosoagentimages
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource Microsoft_Storage_storageAccounts_tableServices_stcontosoagentimages_default 'Microsoft.Storage/storageAccounts/tableServices@2021-04-01' = {
  parent: stcontosoagentimages
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource sig_contoso_agent_Ubuntu1604_1_1_63 'Microsoft.Compute/galleries/images/versions@2020-09-30' = {
  parent: sig_contoso_agent_Ubuntu1604
  name: '1.1.63'
  location: 'eastus2'
  properties: {
    publishingProfile: {
      targetRegions: [
        {
          name: 'East US 2'
          regionalReplicaCount: 1
          storageAccountType: 'Standard_LRS'
        }
      ]
      replicaCount: 1
      excludeFromLatest: false
      storageAccountType: 'Standard_LRS'
    }
    storageProfile: {
      source: {
        id: '/subscriptions/cbadc96b-2923-4459-bb2d-b237af7f84d6/resourceGroups/contoso-agentimages/providers/Microsoft.Compute/images/packer-Ubuntu1604-20210504.3'
      }
      osDiskImage: {
        hostCaching: 'None'
        source: {}
      }
    }
  }
  dependsOn: [
    sig_contoso_agent
  ]
}

resource sig_contoso_agent_Ubuntu2004_1_1_33 'Microsoft.Compute/galleries/images/versions@2020-09-30' = {
  parent: sig_contoso_agent_Ubuntu2004
  name: '1.1.33'
  location: 'eastus2'
  properties: {
    publishingProfile: {
      targetRegions: [
        {
          name: 'East US 2'
          regionalReplicaCount: 1
          storageAccountType: 'Standard_LRS'
        }
      ]
      replicaCount: 1
      excludeFromLatest: false
      storageAccountType: 'Standard_LRS'
    }
    storageProfile: {
      source: {
        id: '/subscriptions/cbadc96b-2923-4459-bb2d-b237af7f84d6/resourceGroups/contoso-agentimages/providers/Microsoft.Compute/images/packer-Ubuntu2004-20210304.3'
      }
      osDiskImage: {
        hostCaching: 'None'
        source: {}
      }
    }
  }
  dependsOn: [
    sig_contoso_agent
  ]
}

resource sig_contoso_agent_Ubuntu2004_1_1_41 'Microsoft.Compute/galleries/images/versions@2020-09-30' = {
  parent: sig_contoso_agent_Ubuntu2004
  name: '1.1.41'
  location: 'eastus2'
  properties: {
    publishingProfile: {
      targetRegions: [
        {
          name: 'East US 2'
          regionalReplicaCount: 1
          storageAccountType: 'Standard_LRS'
        }
      ]
      replicaCount: 1
      excludeFromLatest: false
      storageAccountType: 'Standard_LRS'
    }
    storageProfile: {
      source: {
        id: '/subscriptions/cbadc96b-2923-4459-bb2d-b237af7f84d6/resourceGroups/contoso-agentimages/providers/Microsoft.Compute/images/packer-Ubuntu2004-20210304.12'
      }
      osDiskImage: {
        hostCaching: 'None'
        source: {}
      }
    }
  }
  dependsOn: [
    sig_contoso_agent
  ]
}

resource sig_contoso_agent_Ubuntu2004_1_1_44 'Microsoft.Compute/galleries/images/versions@2020-09-30' = {
  parent: sig_contoso_agent_Ubuntu2004
  name: '1.1.44'
  location: 'eastus2'
  properties: {
    publishingProfile: {
      targetRegions: [
        {
          name: 'East US 2'
          regionalReplicaCount: 1
          storageAccountType: 'Standard_LRS'
        }
      ]
      replicaCount: 1
      excludeFromLatest: false
      storageAccountType: 'Standard_LRS'
    }
    storageProfile: {
      source: {
        id: '/subscriptions/cbadc96b-2923-4459-bb2d-b237af7f84d6/resourceGroups/contoso-agentimages/providers/Microsoft.Compute/images/packer-Ubuntu2004-20210304.15'
      }
      osDiskImage: {
        hostCaching: 'None'
        source: {}
      }
    }
  }
  dependsOn: [
    sig_contoso_agent
  ]
}

resource sig_contoso_agent_Ubuntu2004_1_1_47 'Microsoft.Compute/galleries/images/versions@2020-09-30' = {
  parent: sig_contoso_agent_Ubuntu2004
  name: '1.1.47'
  location: 'eastus2'
  properties: {
    publishingProfile: {
      targetRegions: [
        {
          name: 'East US 2'
          regionalReplicaCount: 1
          storageAccountType: 'Standard_LRS'
        }
      ]
      replicaCount: 1
      excludeFromLatest: false
      storageAccountType: 'Standard_LRS'
    }
    storageProfile: {
      source: {
        id: '/subscriptions/cbadc96b-2923-4459-bb2d-b237af7f84d6/resourceGroups/contoso-agentimages/providers/Microsoft.Compute/images/packer-Ubuntu2004-20210304.18'
      }
      osDiskImage: {
        hostCaching: 'None'
        source: {}
      }
    }
  }
  dependsOn: [
    sig_contoso_agent
  ]
}

resource sig_contoso_agent_Ubuntu2004_1_1_52 'Microsoft.Compute/galleries/images/versions@2020-09-30' = {
  parent: sig_contoso_agent_Ubuntu2004
  name: '1.1.52'
  location: 'eastus2'
  properties: {
    publishingProfile: {
      targetRegions: [
        {
          name: 'East US 2'
          regionalReplicaCount: 1
          storageAccountType: 'Standard_LRS'
        }
      ]
      replicaCount: 1
      excludeFromLatest: false
      storageAccountType: 'Standard_LRS'
    }
    storageProfile: {
      source: {
        id: '/subscriptions/cbadc96b-2923-4459-bb2d-b237af7f84d6/resourceGroups/contoso-agentimages/providers/Microsoft.Compute/images/packer-Ubuntu2004-20210308.3'
      }
      osDiskImage: {
        hostCaching: 'None'
        source: {}
      }
    }
  }
  dependsOn: [
    sig_contoso_agent
  ]
}

resource sig_contoso_agent_Windows2019_1_1_59 'Microsoft.Compute/galleries/images/versions@2020-09-30' = {
  parent: sig_contoso_agent_Windows2019
  name: '1.1.59'
  location: 'eastus2'
  properties: {
    publishingProfile: {
      targetRegions: [
        {
          name: 'East US 2'
          regionalReplicaCount: 1
          storageAccountType: 'Standard_LRS'
        }
      ]
      replicaCount: 1
      excludeFromLatest: false
      storageAccountType: 'Standard_LRS'
    }
    storageProfile: {
      source: {
        id: '/subscriptions/cbadc96b-2923-4459-bb2d-b237af7f84d6/resourceGroups/contoso-agentimages/providers/Microsoft.Compute/images/packer-Windows2019-20210311.3'
      }
      osDiskImage: {
        hostCaching: 'None'
        source: {}
      }
    }
  }
  dependsOn: [
    sig_contoso_agent
  ]
}

resource acrcontosoadoagent_acrcontosoadoagent_01c287678a6f47e59dbbdb9f419ed5b9 'Microsoft.ContainerRegistry/registries/privateEndpointConnections@2020-11-01-preview' = {
  parent: acrcontosoadoagent
  name: 'acrcontosoadoagent.01c287678a6f47e59dbbdb9f419ed5b9'
  properties: {
    privateEndpoint: {
      id: pe_agent.id
    }
    privateLinkServiceConnectionState: {
      status: 'Approved'
      description: 'Auto-Approved'
    }
  }
}

resource stcontosoagentimages_default_images 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {
  parent: stcontosoagentimages_default
  name: 'images'
  properties: {
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  dependsOn: [
    stcontosoagentimages
  ]
}

resource stcontosoagentimages_default_system 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {
  parent: stcontosoagentimages_default
  name: 'system'
  properties: {
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  dependsOn: [
    stcontosoagentimages
  ]
}

resource sig_contoso_agent_Ubuntu1604_1_1_62 'Microsoft.Compute/galleries/images/versions@2020-09-30' = {
  parent: sig_contoso_agent_Ubuntu1604
  name: '1.1.62'
  location: 'eastus2'
  properties: {
    publishingProfile: {
      targetRegions: [
        {
          name: 'East US 2'
          regionalReplicaCount: 1
          storageAccountType: 'Standard_LRS'
        }
      ]
      replicaCount: 1
      excludeFromLatest: false
      storageAccountType: 'Standard_LRS'
    }
    storageProfile: {
      source: {
        id: Microsoft_Compute_images_packer_Ubuntu1604_20210504_2.id
      }
      osDiskImage: {
        hostCaching: 'None'
        source: {}
      }
    }
  }
  dependsOn: [
    sig_contoso_agent
  ]
}
