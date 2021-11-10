@description('The virtual machine name.')
param vmName string

@description('The network interface name.')
param nicName string

@description('The location for the VMs and NICs.')
param location string

@description('Tags for the VM machines and associated resources like disks.')
param vmTags object = {}

@description('Tags for the NICs.')
param nicTags object = {}

@description('IP address allocation method.')
@allowed([
  'Dynamic'
  'Static'
])
param privateIPAddressAllocationMethod string = 'Dynamic'

@description('The IP configuration name.')
param ipConfigurationName string

@description('The Azure DevOps (ADO) agent pool name.')
param agentPool string

@secure()
@description('The personal access token (PAT) used to setup the agent in the agent pool in ADO.')
param pat string

@description('The URL of the ADO organization.')
param orgUrl string

@description('The agent version tag used to identify the agent software release. Optional. Use "latest" to specificy latest of specific tag otherwise. e.g. "v2.194.0')
param agentVersionTag string = 'latest'

@description('Specifies the size of the virtual machine.')
param vmSize string

@description('Specifies the storage account type for the managed disk.')
param osDiskType string

@description('Specifies the name of the administrator account.')
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

param existingStorageAccountName string

param containerName string = 'scriptextensions'

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

param scriptExtensionScriptUris array 

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: existingSubnetName
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
  name: existingVnetName
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2021-02-01' existing = {
  name: existingNetworkSecurityGroupName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' existing = {
  name: existingStorageAccountName
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2021-04-01' = {
  parent: storageAccount
  name: 'default'
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {
  parent: blobService
  name: containerName
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

resource agentextension 'Microsoft.Compute/virtualMachines/extensions@2021-04-01' = [for i in range(0,vmCount):  {
  name: '${virtualMachine[i].name}/agentextension'
  location: location
  tags: vmTags
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: scriptExtensionScriptUris
      commandToExecute: 'sudo ./installer-agent-extension.sh ${adminUsername} ${agentPool} ${pat} ${orgUrl} ${agentVersionTag}'
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
output containerName string = containerName
