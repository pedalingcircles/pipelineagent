@description('The virtual machine scale set name.')
param vmssName string

@description('Azure region to create resources in.')
param location string = resourceGroup().location

@description('The set of key valure paris of tags to apply to resources.')
param tags object = {}

@description('Specifies the number of virtual machines in the scale set.')
param skuCapacity int = 2

param skuTier string = 'Standard'

param imageDefinitionName string

@description('Virtual machine size.')
param vmSize string


var osSettings = {
  Linux: {
    diskSize: 86
  }
  Windows: {
    diskSize: 256
  }
}

@description('The network interface name.')
param nicName string

@allowed([
  'Linux'
  'Windows'
])
param osType string

param computerNameAffix string

@description('The SSH RSA public key file as a string. Use "ssh-keygen -t rsa -b 2048" to generate your SSH key pairs.')
param adminPublicKey string
param storageAccountType string = 'StandardSSD_LRS'

param existingVnetName string

@description('The admin user account created when provisioning the VM.')
param adminUserName string = 'azureuser'

param existingShareImageGalleryName string 

param existingImagesResourceGroupName string

resource sharedImageGallery 'Microsoft.Compute/galleries@2020-09-30' existing = {
  name: existingShareImageGalleryName
  scope: resourceGroup(existingImagesResourceGroupName)
}

var computerNamePrefix = 'vm${computerNameAffix}'

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
  name: existingVnetName
}

resource virtualmachinescaleset 'Microsoft.Compute/virtualMachineScaleSets@2021-04-01' = {
  name: vmssName
  location: location
  tags: tags
  sku: {
    name: vmSize
    tier: skuTier
    capacity: skuCapacity
  }
  identity: {
    type: 'None'
  }
  properties: {
    singlePlacementGroup: false
    upgradePolicy: {
      mode: 'Manual'
      rollingUpgradePolicy: {
        maxBatchInstancePercent: 20
        maxUnhealthyInstancePercent: 20
        maxUnhealthyUpgradedInstancePercent: 20
        pauseTimeBetweenBatches: 'PT0S'
      }
    }
    virtualMachineProfile: {
      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: nicName
            properties: {
              primary: true
              enableAcceleratedNetworking: false
              dnsSettings: {
                dnsServers: []
              }
              enableIPForwarding: false
              ipConfigurations: [
                {
                  name: 'ipconfig1'
                  properties: {
                    subnet: {
                      id: vnet.properties.subnets[0].id
                    }
                    privateIPAddressVersion: 'IPv4'
                  }
                }
              ]
            }
          }
        ]
      }
      osProfile: {
        computerNamePrefix: computerNamePrefix
        adminUsername: adminUserName
        linuxConfiguration: {
          disablePasswordAuthentication: true
          provisionVMAgent: true
          ssh: {
            publicKeys: [
              {
                keyData: adminPublicKey
                path: '/home/${adminUserName}/.ssh/authorized_keys'
              }
            ]
          }
        }
      }
      storageProfile: {
        osDisk: {
          osType: osType
          diffDiskSettings: {
            option: 'Local'
            placement: 'CacheDisk'
          }
          createOption: 'FromImage'
          caching: 'ReadOnly'
          managedDisk: {
            storageAccountType: storageAccountType
          }
          diskSizeGB: osSettings[osType].diskSize
        }
        imageReference: {
          id: '${sharedImageGallery.id}/images/${imageDefinitionName}'
        }
      }
    }
    overprovision: false
    doNotRunExtensionsOnOverprovisionedVMs: false
    platformFaultDomainCount: 1
  }
}
