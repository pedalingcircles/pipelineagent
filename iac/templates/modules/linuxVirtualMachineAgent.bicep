param name string
param location string
param tags object = {}

param networkInterfaceName string

param vmSize string
param osDiskType string
param adminUsername string
@allowed([
  'sshPublicKey'
  'password'
])
param authenticationType string

@description('The SSH RSA public key file as a string. Use "ssh-keygen -t rsa -b 2048" to generate your SSH key pairs.')
@secure()
@minLength(14)
param adminPublicKey  string

param sharedImageGalleryName string
param imageResourceGroupName string

@description('The start index of how many VMs to provision.')
param vmCountStart int = 0
@description('The number of VMs to provision.')
param vmCount int = 1
param imageDefinitionName string

var linuxConfiguration = {
  disablePasswordAuthentication: true
  ssh: {
    publicKeys: [
      {
        path: '/home/${adminUsername}/.ssh/authorized_keys'
        keyData: adminPublicKey 
      }
    ]
  }
}

resource sharedImageGallery 'Microsoft.Compute/galleries@2020-09-30' existing = {
  name: sharedImageGalleryName
  scope: resourceGroup(imageResourceGroupName)
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2021-02-01' existing = {
  name: networkInterfaceName
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2021-03-01' = [for i in range(vmCountStart, vmCount): {
  name: '${name}${i}'
  location: location
  tags: tags

  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
      }
      imageReference: {
        id: '${sharedImageGallery.id}/images/${imageDefinitionName}'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
    osProfile: {
      computerName: name
      adminUsername: adminUsername
      linuxConfiguration: linuxConfiguration
    }
  }
}]

output adminUsername string = adminUsername
output authenticationType string = authenticationType
