@description('The virtual machine name.')
param vmName string

@description('The network interface name.')
param nicName string

@description('The location for the VMs and NICs.')
param location string

param vmTags object = {}
param nicTags object = {}

param privateIPAddressAllocationMethod string = 'Dynamic'
param ipConfigurationName string

param vmSize string
param osDiskType string
param adminUsername string

@description('The SSH RSA public key file as a string. Use "ssh-keygen -t rsa -b 2048" to generate your SSH key pairs.')
@minLength(14)
param adminPublicKey  string

@description('The existing Shared Image Gallery name.')
param existingSharedImageGalleryName string

@description('The existing image resource group name.')
param existingImageResourceGroupName string

@description('The number of VMs to provision.')
param vmCount int = 2

@description('The image definition to use. This value is in the Shared Image Gallery')
param imageDefinitionName string

@description('The image definition version ot use.')
param imageDefinitionVersion string

@description('The existing subnet name in the virtual network that hosts the VMs.')
param existingSubnetName string

@description('The existing network security group name in the virtual network that hosts the VMs.')
param existingNetworkSecurityGroupName string

@description('The existing virtual network name that hosts the VMs.')
param existingVnetName string

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

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: existingSubnetName
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
  name: existingVnetName
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2021-02-01' existing = {
  name: existingNetworkSecurityGroupName
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2020-11-01' = [for i in range(0, vmCount): {
  name: '${nicName}-${format('{0:000}', i)}'
  location: location
  tags: nicTags

  properties: {
    ipConfigurations: [
      {
        name: ipConfigurationName
        properties: {
          subnet: {
            id: '${vnet.id}/subnets/${subnet.name}'
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
          privateIPAllocationMethod: privateIPAddressAllocationMethod
        }
      }
    ]
    networkSecurityGroup: {
      id: networkSecurityGroup.id
    }
  }
}]


resource sharedImageGallery 'Microsoft.Compute/galleries@2020-09-30' existing = {
  name: existingSharedImageGalleryName
  scope: resourceGroup(existingImageResourceGroupName)
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2021-03-01' = [for i in range(0, vmCount): {
  name: '${vmName}${i}'
  location: location
  tags: vmTags
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
        id: '${sharedImageGallery.id}/images/${imageDefinitionName}/versions/${imageDefinitionVersion}'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface[i].id
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

output vmCountStop int = vmCount
output nicInfo array = [for i in range(0, vmCount): {
  id: networkInterface[i].id
  name: networkInterface[i].name
}]
output adminUsername string = adminUsername
output authenticationType string = 'sshPublicKey'
