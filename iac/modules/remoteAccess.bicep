param location string
param tags object = {}

param hubVirtualNetworkName string
param hubSubnetResourceId string
param hubNetworkSecurityGroupResourceId string

param bastionHostName string
param bastionHostSubnetAddressPrefix string
param bastionHostPublicIPAddressName string
param bastionHostPublicIPAddressSkuName string 
param bastionHostPublicIPAddressAllocationMethod string
param bastionHostPublicIPAddressAvailabilityZones array
param bastionHostIPConfigurationName string

param linuxNetworkInterfaceName string
param linuxNetworkInterfaceIpConfigurationName string
param linuxNetworkInterfacePrivateIPAddressAllocationMethod string

param linuxVmName string
param linuxVmSize string
param linuxVmOsDiskCreateOption string
param linuxVmOsDiskType string
param linuxVmImagePublisher string
param linuxVmImageOffer string 
param linuxVmImageSku string
param linuxVmImageVersion string
param linuxVmAdminUsername string
@allowed([
  'sshPublicKey'
  'password'
])
param linuxVmAuthenticationType string
@secure()
@minLength(14)
param linuxVmAdminPasswordOrKey string

param windowsNetworkInterfaceName string
param windowsNetworkInterfaceIpConfigurationName string
param windowsNetworkInterfacePrivateIPAddressAllocationMethod string

param windowsVmName string
param windowsVmSize string
param windowsVmAdminUsername string
@secure()
@minLength(14)
param windowsVmAdminPassword string
param windowsVmPublisher string
param windowsVmOffer string
param windowsVmSku string
param windowsVmVersion string
param windowsVmCreateOption string
param windowsVmStorageAccountType string

param nowUtc string = utcNow()

resource hubVirtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: hubVirtualNetworkName
}

module bastionHost './bastionHost.bicep' = {
  name: 'deploy-remote-access-bastionhost-${nowUtc}'
  params: {
    name: bastionHostName
    location: location
    tags: tags

    virtualNetworkName: hubVirtualNetwork.name
    subnetAddressPrefix: bastionHostSubnetAddressPrefix
    publicIPAddressName: bastionHostPublicIPAddressName
    publicIPAddressSkuName: bastionHostPublicIPAddressSkuName
    publicIPAddressAllocationMethod: bastionHostPublicIPAddressAllocationMethod
    publicIPAddressAvailabilityZones: bastionHostPublicIPAddressAvailabilityZones
    ipConfigurationName: bastionHostIPConfigurationName
  }
}

module linuxNetworkInterface './networkInterface.bicep' = {
  name: 'deploy-remote-access-linux-nic-${nowUtc}'
  params: {
    name: linuxNetworkInterfaceName
    location: location
    tags: tags
    
    ipConfigurationName: linuxNetworkInterfaceIpConfigurationName
    networkSecurityGroupId: hubNetworkSecurityGroupResourceId
    privateIPAddressAllocationMethod: linuxNetworkInterfacePrivateIPAddressAllocationMethod
    subnetId: hubSubnetResourceId
  }
}

module linuxVirtualMachine './linuxVirtualMachine.bicep' = {
  name: 'deploy-remote-access-linux-vm-${nowUtc}'
  params: {
    name: linuxVmName
    location: location
    tags: tags

    vmSize: linuxVmSize
    osDiskCreateOption: linuxVmOsDiskCreateOption
    osDiskType: linuxVmOsDiskType
    vmImagePublisher: linuxVmImagePublisher
    vmImageOffer: linuxVmImageOffer
    vmImageSku: linuxVmImageSku
    vmImageVersion: linuxVmImageVersion
    adminUsername: linuxVmAdminUsername
    authenticationType: linuxVmAuthenticationType
    adminPasswordOrKey: linuxVmAdminPasswordOrKey
    networkInterfaceName: linuxNetworkInterface.outputs.name
  }
}

module windowsNetworkInterface './networkInterface.bicep' = {
  name: 'deploy-remote-access-windows-nic-${nowUtc}'
  params: {
    name: windowsNetworkInterfaceName
    location: location
    tags: tags
    
    ipConfigurationName: windowsNetworkInterfaceIpConfigurationName
    networkSecurityGroupId: hubNetworkSecurityGroupResourceId
    privateIPAddressAllocationMethod: windowsNetworkInterfacePrivateIPAddressAllocationMethod
    subnetId: hubSubnetResourceId
  }
}

module windowsVirtualMachine './windowsVirtualMachine.bicep' = {
  name: 'deploy-remote-access-windows-vm-${nowUtc}'
  params: {
    name: windowsVmName
    location: location
    tags: tags

    size: windowsVmSize
    adminUsername: windowsVmAdminUsername
    adminPassword: windowsVmAdminPassword
    publisher: windowsVmPublisher
    offer: windowsVmOffer
    sku: windowsVmSku
    version: windowsVmVersion
    createOption: windowsVmCreateOption
    storageAccountType: windowsVmStorageAccountType
    networkInterfaceName: windowsNetworkInterface.outputs.name
  }
}
