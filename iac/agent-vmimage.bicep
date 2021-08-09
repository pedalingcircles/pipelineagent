param vmName string
param vmSize string = 'Standard_D4s_v4'
param adminUserName string

@secure()
param adminPassword string
param networkInterfaceId string

resource vmName_resource 'Microsoft.Compute/virtualMachines@2018-04-01' = {
  name: vmName
  location: 'eastus'
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      osDisk: {
        osType: 'Linux'
        name: '23823-osDisk.8b3ea017-3c44-473c-8dc9-a4aee5a4c0ae.vhd'
        createOption: 'FromImage'
        image: {
          uri: 'https://contosopackerbuilder001.blob.core.windows.net/system/Microsoft.Compute/Images/images/23823-osDisk.8b3ea017-3c44-473c-8dc9-a4aee5a4c0ae.vhd'
        }
        vhd: {
          uri: 'https://contosopackerbuilder001.blob.core.windows.net/vmcontainer9473df9a-cd60-40db-bcb9-ed919122686e/osDisk.9473df9a-cd60-40db-bcb9-ed919122686e.vhd'
        }
        caching: 'ReadWrite'
      }
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUserName
      adminPassword: adminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaceId
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
      }
    }
    provisioningState: 0
  }
}