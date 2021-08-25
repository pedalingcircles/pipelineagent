// Azure resource names cannot contain special characters \/""[]:|<>+=;,?*@&, whitespace, or begin with '_' or end with '.' or '-'
// Linux VM names may only contain letters, numbers, '.', and '-'.
param vmNameAffix string

// example nic-<##>-<nicNameAffix>-<###>
@description('The network interface name.')
@minLength(2)
@maxLength(64)
param nicNameAffix string
param vmSize string = 'Standard_D4s_v4'
param storageAccountType string = 'StandardSSD_LRS'
param vmCountStart int
param vmCountEnd int
param location string = resourceGroup().location

@description('Specifies the SSH rsa public key file as a string. Use "ssh-keygen -t rsa -b 2048" to generate your SSH key pairs.')
param adminPublicKey string

@allowed([
  'Linux'
  'Windows'
])
param osType string


param adminUserName string = 'azureuser'
param existingVnetName string
param existingShareImageGalleryName string 
param existingImagesResourceGroupName string
param imageDefinitionName string

var nicName = 'nic-${nicNameAffix}'
var vmName = 'vm${vmNameAffix}'
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

resource virtualmachine 'Microsoft.Compute/virtualMachines@2021-03-01' = [for i in range(vmCountStart,vmCountEnd):  {
  name: '${vmName}${i}'
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

var scriptExtensionFileUris = [
  'https://raw.githubusercontent.com/pedalingcircles/pipelineagent/scriptextension/helpers/echo.sh'
]

resource agentextension 'Microsoft.Compute/virtualMachines/extensions@2021-04-01' = [for i in range(vmCountStart,vmCountEnd):  {
  name: '${virtualmachine[i].name}/agentextension'
  location: location
  tags: {
    foo: 'bar'
    bang: 'buzz'
  }
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    autoUpgradeMinorVersion: true
    settings: {
    }
    protectedSettings: {
      commandToExecute: 'sudo sh echo.sh'
      fileUris: scriptExtensionFileUris
    }
  }
}]

resource networkInterface 'Microsoft.Network/networkInterfaces@2020-11-01' = [for i in range(vmCountStart,vmCountEnd):  {
  name: '${nicName}${i}'
  location: location
  tags: {
    foo: 'bar'
    bang: 'buzz'
  }
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
