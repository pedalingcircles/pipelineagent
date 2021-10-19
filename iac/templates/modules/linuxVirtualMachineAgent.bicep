@description('The virtual machine name.')
param vmName string

@description('The network interface name. There will be a prefix and suffix attached to this affix.')
param nicName string

@description('The location for VMs and NICs.')
param location string

param tags object = {}

param privateIPAddressAllocationMethod string = 'Dynamic'
param ipConfigurationName string

param vmSize string
param osDiskType string
param adminUsername string

@description('The SSH RSA public key file as a string. Use "ssh-keygen -t rsa -b 2048" to generate your SSH key pairs.')
@minLength(14)
param adminPublicKey  string

param existingSharedImageGalleryName string
param existingImageResourceGroupName string

@description('The start index of how many VMs to provision.')
param vmCountStart int = 0
@description('The number of VMs to provision.')
param vmCount int = 1
param imageDefinitionName string

param existingNetworkSecurityGroupName string
param existingSubnetName string


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
  name: existingSharedImageGalleryName
  scope: resourceGroup(existingImageResourceGroupName)
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2021-03-01' = [for i in range(vmCountStart, vmCount): {
  name: '${vmName}${i}'
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
          id: networkInterface[0].id
        }
      ]
    }
    osProfile: {
      computerName: '${vmName}${i}'
      adminUsername: adminUsername
      linuxConfiguration: linuxConfiguration
    }
  }
}]


resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2021-02-01' existing = {
  name: existingNetworkSecurityGroupName
}


resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: existingSubnetName
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2021-02-01' = [for i in range(vmCountStart,vmCount): {
  name: '${nicName}${i}'
  location: location
  tags: tags

  properties: {
    ipConfigurations: [
      {
        name: ipConfigurationName
        properties: {
          subnet: {
            id: subnet.id
          }
          primary: true
          privateIPAllocationMethod: privateIPAddressAllocationMethod
        }
      }
    ]
    networkSecurityGroup: {
      id: networkSecurityGroup.id
    }
  }
}]

output vmCount int = vmCount
output vmCountStart int = vmCountStart
output adminUsername string = adminUsername
output authenticationType string = 'sshPublicKey'
