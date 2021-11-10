@description('The virtual machine name. There will likely be a prefix and suffix attached to this affix.')
param vmNameAffix string

@description('The network interface name.')
param nicNameAffix string

@description('Virtual machine size.')
param vmSize string = 'Standard_D8s_v3'

@description('The storage account type.')
@allowed([
  'Premium_LRS'
  'Premium_ZRS'
  'StandardSSD_LRS'
  'StandardSSD_ZRS'
  'Standard_LRS'
  'UltraSSD_LRS'
])
param storageAccountType string = 'StandardSSD_LRS'

@description('The start index of how many VMs to provision.')
param vmCountStart int = 0

@description('The number of VMs to provision.')
param vmCount int = 4

@description('Azure region to create resources in.')
param location string = resourceGroup().location

@description('The SSH RSA public key file as a string. Use "ssh-keygen -t rsa -b 2048" to generate your SSH key pairs.')
param adminPublicKey string

@description('The set of key valure paris of tags to apply to resources.')
param tags object = {}

@description('The operating system of the osDiskImage.')
@allowed([
  'Linux'
  'Windows'
])
param osType string = 'Linux'

@description('Blue/Gree decorator to support Blue Green.')
@allowed([
  'b'
  'g'
])
param blueGreen string = 'b'

@description('The admin user account created when provisioning the VM.')
param adminUserName string = 'azureuser'

@description('The existing virtual network.')
param existingVnetName string

@description('The existing Shared Image Gallery.')
param existingShareImageGalleryName string 

@description('The existing resource group name that stores all the images.')
param existingImagesResourceGroupName string

@description('The image definition name used to provision the VM(s).')
param imageDefinitionName string

var nicName = 'nic-${nicNameAffix}'
var vmName = 'vm${vmNameAffix}${blueGreen}'
var osSettings = {
  Linux: {
    diskSize: 86
  }
  Windows: {
    diskSize: 256
  }
}

resource sharedImageGallery 'Microsoft.Compute/galleries@2020-09-30' existing = {
  name: existingShareImageGalleryName
  scope: resourceGroup(existingImagesResourceGroupName)
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
  name: existingVnetName
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2020-11-01' = [for i in range(0,vmCount): {
  name: '${nicName}${i}'
  location: location
  tags: tags
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
}]

resource virtualmachine 'Microsoft.Compute/virtualMachines@2021-03-01' = [for i in range(vmCountStart,vmCount):  {
  name: '${vmName}${i}'
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        id: '${sharedImageGallery.id}/images/${imageDefinitionName}'
      }
      osDisk: {
        osType: osType
        name: '${vmName}${i}_OsDisk_1_${uniqueString(resourceGroup().id)}'
        createOption: 'FromImage'
        caching: 'None'
        managedDisk: {
          storageAccountType: storageAccountType
        }
        diskSizeGB: osSettings[osType].diskSize
      }
      dataDisks: []
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUserName
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUserName}/.ssh/authorized_keys'
              keyData: adminPublicKey
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
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface[i].id
        }
      ]
    }
  }
}]




// var scriptExtensionFileUris = [
//   'https://raw.githubusercontent.com/pedalingcircles/pipelineagent/vmscaleset/scripts/installer-agent-extension.sh'
// ]

// resource agentextension 'Microsoft.Compute/virtualMachines/extensions@2021-04-01' = [for i in range(vmCountStart,vmCount):  {
//   name: '${virtualmachine[i].name}/agentextension'
//   location: location
//   tags: tags
//   properties: {
//     publisher: 'Microsoft.Azure.Extensions'
//     type: 'CustomScript'
//     typeHandlerVersion: '2.1'
//     autoUpgradeMinorVersion: true
//     settings: {
//     }
//     protectedSettings: {
//       //commandToExecute: 'sudo sh echo.sh'
//       commandToExecute: 'sudo ./scriptextensionlinux.sh ${agentUser} ${agentPool} ${agentToken} ${adoUrl} ${agentVersion}'
//       fileUris: scriptExtensionFileUris
//     }
//   }
// }]
                                                                     