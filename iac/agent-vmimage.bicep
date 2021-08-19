// Azure resource names cannot contain special characters \/""[]:|<>+=;,?*@&, whitespace, or begin with '_' or end with '.' or '-'
// Linux VM names may only contain letters, numbers, '.', and '-'.
// vm
// agent
// linux or windows
//ubuntu2004
vm-team-product/workload/templatename-0001
param vmName string
param vmSize string = 'Standard_D4s_v4'
param storageAccountType string = 'StandardSSD_LRS'
param vmCountStart int = 0
param vmCountEnd int = 10
param location string = resourceGroup().location
param osType string
param adminUserName string = 'azureuser'
param existingVnet string
param existingShareImageGalleryName string 
param existingImagesResourceGroupName string

resource sharedImageGallery 'Microsoft.Compute/galleries@2020-09-30' existing = {
  name: existingShareImageGalleryName
  scope: resourceGroup(existingImagesResourceGroupName)
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
  name: existingVnet
}


resource virtualmachine 'Microsoft.Compute/virtualMachines@2021-03-01' = [for i in range (vmCountStart, vmCountEnd): {
  name: '${vmName}${padLeft(i, 3, '0')}'
  location: location
  tags: {
    foo: 'bar'
    bang: 'buzz'
  }
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        id: '${sharedImageGallery.id}/images/ubuntu2004'
      }
      osDisk: {
        osType: osType
        name: '${vmName}${padLeft(i, 3, '0')}_OsDisk_1_${uniqueString(resourceGroup().id)}'
        createOption: 'FromImage'
        caching: 'None'
        managedDisk: {
          storageAccountType: storageAccountType
          id: resourceId('Microsoft.Compute/disks', '${vmName}${padLeft(i, 3, '0')}_OsDisk_1_${uniqueString(resourceGroup().id)}')
        }
        diskSizeGB: 86
      }
      dataDisks: []
    }
    osProfile: {
      computerName: '${vmName}${padLeft(i, 3, '0')}'
      adminUsername: adminUserName
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/azureuser/.ssh/authorized_keys'
              keyData: 'ssh-rsa notakey= generated-by-azure\r\n'
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
      networkInterfaceConfigurations: [
        {
          name: 'nic-${vmName}${padLeft(i, 3, '0')}'
          properties: {
            ipConfigurations: [
              {
                name: 'ipconfig1'
                properties: {
                  privateIPAllocationMethod: 'Dynamic'
                  subnet: {
                    id: vnet.properties.subnets[0].id
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
    ]
    }
  }
}]
