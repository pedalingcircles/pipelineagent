// scope
targetScope = 'subscription'

// Can optionally use resource group here as a scope
param uniqueId string = uniqueString(deployment().name)

param envType string
param organization string
param workload string = 'pipelineagent'

param resourceAffix string = '${workload}-${uniqueId}'
param nowUtc string = utcNow()

param hubResourceGroupName string = 'rg-${resourceAffix}-hub'
param agentResourceGroupName string = 'rg-${resourceAffix}-agent'
param imageBuilderResourceGroupName string = 'rg-${resourceAffix}-imagebuilder'
param imageResourceGroupName string = 'rg-${resourceAffix}-image'
param operationsResourceGroupName string = 'rg-${resourceAffix}-operations'

param hubSubscriptionId string = subscription().subscriptionId
param agentSubscriptionId string = subscription().subscriptionId
param imageBuilderubscriptionId string = subscription().subscriptionId
param imageSubscriptionId string = subscription().subscriptionId
param operationsSubscriptionId string = subscription().subscriptionId

param hubLocation string = deployment().location
param agentLocation string = deployment().location
param imageBuilderLocation string = deployment().location
param imageLocation string = deployment().location
param operationsLocation string = deployment().location

param logAnalyticsWorkspaceName string = take('${resourceAffix}-laws', 63)
param logAnalyticsWorkspaceRetentionInDays int = 30
param logAnalyticsWorkspaceSkuName string = 'PerGB2018'
param logAnalyticsWorkspaceCappingDailyQuotaGb int = -1

// hub networking
param hubLogStorageAccountName string = toLower(take('sthublogs${uniqueId}', 24))
param hubLogStorageSkuName string = 'Standard_GRS'
param hubVirtualNetworkName string = 'hub-vnet'
param hubVirtualNetworkAddressPrefix string = '10.0.100.0/24'
param hubVirtualNetworkDiagnosticsLogs array = []
param hubVirtualNetworkDiagnosticsMetrics array = []
param hubNetworkSecurityGroupName string = 'hub-nsg'
param hubNetworkSecurityGroupRules array = []
param hubSubnetName string = 'hub-subnet'
param hubSubnetAddressPrefix string = '10.0.100.128/27'
param hubSubnetServiceEndpoints array = []
param firewallName string = 'firewall'
param firewallSkuTier string = 'Premium'
param firewallPolicyName string = 'firewall-policy'
param firewallThreatIntelMode string = 'Alert'
param firewallClientIpConfigurationName string = 'firewall-client-ip-config'
var firewallClientSubnetName = 'AzureFirewallSubnet' //this must be 'AzureFirewallSubnet'
param firewallClientSubnetAddressPrefix string = '10.0.100.0/26'
param firewallClientSubnetServiceEndpoints array = []
param firewallClientPublicIPAddressName string = 'firewall-client-public-ip'
param firewallClientPublicIPAddressSkuName string = 'Standard'
param firewallClientPublicIpAllocationMethod string = 'Static'
param firewallClientPublicIPAddressAvailabilityZones array = []
param firewallManagementIpConfigurationName string = 'firewall-management-ip-config'
var firewallManagementSubnetName = 'AzureFirewallManagementSubnet' //this must be 'AzureFirewallManagementSubnet'
param firewallManagementSubnetAddressPrefix string = '10.0.100.64/26'
param firewallManagementSubnetServiceEndpoints array = []
param firewallManagementPublicIPAddressName string = 'firewall-management-public-ip'
param firewallManagementPublicIPAddressSkuName string = 'Standard'
param firewallManagementPublicIpAllocationMethod string = 'Static'
param firewallManagementPublicIPAddressAvailabilityZones array = []

param operationsLogStorageAccountName string = toLower(take('opslogs${uniqueId}', 24))
param operationsLogStorageSkuName string = hubLogStorageSkuName
param operationsVirtualNetworkName string = replace(hubVirtualNetworkName, 'hub', 'operations')
param operationsVirtualNetworkAddressPrefix string = '10.0.115.0/26'
param operationsVirtualNetworkDiagnosticsLogs array = []
param operationsVirtualNetworkDiagnosticsMetrics array = []
param operationsNetworkSecurityGroupName string = replace(hubNetworkSecurityGroupName, 'hub', 'operations')
param operationsNetworkSecurityGroupRules array = []
param operationsSubnetName string = replace(hubSubnetName, 'hub', 'operations')
param operationsSubnetAddressPrefix string = '10.0.115.0/27'
param operationsSubnetServiceEndpoints array = []

@allowed([
  'NIST'
  'IL5' // Gov cloud only, trying to deploy IL5 in AzureCloud will switch to NIST
  'CMMC'
  ''
])
@description('Built-in policy assignments to assign, default is none. [NIST/IL5/CMMC] IL5 is only availalbe for GOV cloud and will switch to NIST if tried in AzureCloud.')
param policy string = ''

@description('Provision Azure Bastion Host and jumpboxes in this deployment')
param deployRemoteAccess bool = false
param bastionHostName string = 'bastionHost'
param bastionHostSubnetAddressPrefix string = '10.0.100.160/27'
param bastionHostPublicIPAddressName string = 'bastionHostPublicIPAddress'
param bastionHostPublicIPAddressSkuName string = 'Standard'
param bastionHostPublicIPAddressAllocationMethod string = 'Static'
param bastionHostPublicIPAddressAvailabilityZones array = []
param bastionHostIPConfigurationName string = 'bastionHostIPConfiguration'
param linuxNetworkInterfaceName string = 'linuxVmNetworkInterface'
param linuxNetworkInterfaceIpConfigurationName string = 'linuxVmIpConfiguration'
param linuxNetworkInterfacePrivateIPAddressAllocationMethod string = 'Dynamic'
param linuxVmName string = 'linuxVirtualMachine'
param linuxVmSize string = 'Standard_B2s'
param linuxVmOsDiskCreateOption string = 'FromImage'
param linuxVmOsDiskType string = 'Standard_LRS'
param linuxVmImagePublisher string = 'Canonical'
param linuxVmImageOffer string = 'UbuntuServer'
param linuxVmImageSku string = '18.04-LTS'
param linuxVmImageVersion string = 'latest'
param linuxVmAdminUsername string = 'azureuser'
@allowed([
  'sshPublicKey'
  'password'
])
param linuxVmAuthenticationType string = 'password'
@secure()
@minLength(14)
param linuxVmAdminPasswordOrKey string = deployRemoteAccess ? '' : newGuid()
param windowsNetworkInterfaceName string = 'windowsVmNetworkInterface'
param windowsNetworkInterfaceIpConfigurationName string = 'windowsVmIpConfiguration'
param windowsNetworkInterfacePrivateIPAddressAllocationMethod string = 'Dynamic'
param windowsVmName string = 'windowsVm'
param windowsVmSize string = 'Standard_DS1_v2'
param windowsVmAdminUsername string = 'azureuser'
@secure()
@minLength(14)
param windowsVmAdminPassword string = deployRemoteAccess ? '' : newGuid()
param windowsVmPublisher string = 'MicrosoftWindowsServer'
param windowsVmOffer string = 'WindowsServer'
param windowsVmSku string = '2019-datacenter-gensecond'
param windowsVmVersion string = 'latest'
param windowsVmCreateOption string = 'FromImage'
param windowsVmStorageAccountType string = 'StandardSSD_LRS'

param hubTags object = {
  'envtype': envType
  'org': organization
  'workload': workload
  'component': 'hub'
}
param agentTags object = {
  'envtype': envType
  'org': organization
  'workload': workload
  'component': 'agent'
}
param imageBuilderTags object = {
  'envtype': envType
  'org': organization
  'workload': workload
  'component': 'imagebuilder'
}
param imageTags object = {
  'envtype': envType
  'org': organization
  'workload': workload
  'component': 'image'
}

param operationsTags object = {
  'envtype': envType
  'org': organization
  'workload': workload
  'component': 'operations'
}


module hubResourceGroup './modules/resourceGroup.bicep' = {
  name: 'deploy-hub-rg-${nowUtc}'
  scope: subscription(hubSubscriptionId)
  params: {
    name: hubResourceGroupName
    location: hubLocation
    tags: hubTags
  }
}

module agentResourceGroup './modules/resourceGroup.bicep' = {
  name: 'deploy-agent-rg-${nowUtc}'
  scope: subscription(agentSubscriptionId)
  params: {
    name: agentResourceGroupName
    location: agentLocation
    tags: agentTags
  }
}

module imageBuilderResourceGroup './modules/resourceGroup.bicep' = {
  name: 'deploy-imagebuilder-rg-${nowUtc}'
  scope: subscription(imageBuilderubscriptionId)
  params: {
    name: imageBuilderResourceGroupName
    location: imageBuilderLocation
    tags: imageBuilderTags
  }
}
module imageResourceGroup './modules/resourceGroup.bicep' = {
  name: 'deploy-image-rg-${nowUtc}'
  scope: subscription(imageSubscriptionId)
  params: {
    name: imageResourceGroupName
    location: imageLocation
    tags: imageTags
  }
}

module operationsResourceGroup './modules/resourceGroup.bicep' = {
  name: 'deploy-operations-rg-${nowUtc}'
  scope: subscription(operationsSubscriptionId)
  params: {
    name: operationsResourceGroupName
    location: operationsLocation
    tags: operationsTags
  }
}

module logAnalyticsWorkspace './modules/logAnalyticsWorkspace.bicep' = {
  name: 'deploy-laws-${nowUtc}'
  scope: resourceGroup(operationsSubscriptionId, operationsResourceGroupName)
  params: {
    name: logAnalyticsWorkspaceName
    location: operationsLocation
    tags: operationsTags

    retentionInDays: logAnalyticsWorkspaceRetentionInDays
    skuName: logAnalyticsWorkspaceSkuName
    workspaceCappingDailyQuotaGb: logAnalyticsWorkspaceCappingDailyQuotaGb
  }
  dependsOn: [
    operationsResourceGroup
  ]
}

module hub './modules/hubNetwork.bicep' = {
  name: 'deploy-hub-${nowUtc}'
  scope: resourceGroup(hubSubscriptionId, hubResourceGroupName)
  params: {
    location: hubLocation
    tags: hubTags

    logStorageAccountName: hubLogStorageAccountName
    logStorageSkuName: hubLogStorageSkuName

    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspace.outputs.id

    virtualNetworkName: hubVirtualNetworkName
    virtualNetworkAddressPrefix: hubVirtualNetworkAddressPrefix
    virtualNetworkDiagnosticsLogs: hubVirtualNetworkDiagnosticsLogs
    virtualNetworkDiagnosticsMetrics: hubVirtualNetworkDiagnosticsMetrics

    networkSecurityGroupName: hubNetworkSecurityGroupName
    networkSecurityGroupRules: hubNetworkSecurityGroupRules

    subnetName: hubSubnetName
    subnetAddressPrefix: hubSubnetAddressPrefix
    subnetServiceEndpoints: hubSubnetServiceEndpoints

    firewallName: firewallName
    firewallSkuTier: firewallSkuTier
    firewallPolicyName: firewallPolicyName
    firewallThreatIntelMode: firewallThreatIntelMode
    firewallClientIpConfigurationName: firewallClientIpConfigurationName
    firewallClientSubnetName: firewallClientSubnetName
    firewallClientSubnetAddressPrefix: firewallClientSubnetAddressPrefix
    firewallClientSubnetServiceEndpoints: firewallClientSubnetServiceEndpoints
    firewallClientPublicIPAddressName: firewallClientPublicIPAddressName
    firewallClientPublicIPAddressSkuName: firewallClientPublicIPAddressSkuName
    firewallClientPublicIpAllocationMethod: firewallClientPublicIpAllocationMethod
    firewallClientPublicIPAddressAvailabilityZones: firewallClientPublicIPAddressAvailabilityZones
    firewallManagementIpConfigurationName: firewallManagementIpConfigurationName
    firewallManagementSubnetName: firewallManagementSubnetName
    firewallManagementSubnetAddressPrefix: firewallManagementSubnetAddressPrefix
    firewallManagementSubnetServiceEndpoints: firewallManagementSubnetServiceEndpoints
    firewallManagementPublicIPAddressName: firewallManagementPublicIPAddressName
    firewallManagementPublicIPAddressSkuName: firewallManagementPublicIPAddressSkuName
    firewallManagementPublicIpAllocationMethod: firewallManagementPublicIpAllocationMethod
    firewallManagementPublicIPAddressAvailabilityZones: firewallManagementPublicIPAddressAvailabilityZones
  }
}

module operations './modules/spokeNetwork.bicep' = {
  name: 'deploy-operations-spoke-${nowUtc}'
  scope: resourceGroup(operationsSubscriptionId, operationsResourceGroupName)
  params: {
    location: operationsLocation
    tags: operationsTags

    logStorageAccountName: operationsLogStorageAccountName
    logStorageSkuName: operationsLogStorageSkuName

    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspace.outputs.id

    firewallPrivateIPAddress: hub.outputs.firewallPrivateIPAddress

    virtualNetworkName: operationsVirtualNetworkName
    virtualNetworkAddressPrefix: operationsVirtualNetworkAddressPrefix
    virtualNetworkDiagnosticsLogs: operationsVirtualNetworkDiagnosticsLogs
    virtualNetworkDiagnosticsMetrics: operationsVirtualNetworkDiagnosticsMetrics

    networkSecurityGroupName: operationsNetworkSecurityGroupName
    networkSecurityGroupRules: operationsNetworkSecurityGroupRules

    subnetName: operationsSubnetName
    subnetAddressPrefix: operationsSubnetAddressPrefix
    subnetServiceEndpoints: operationsSubnetServiceEndpoints
  }
}

module hubVirtualNetworkPeerings './modules/hubNetworkPeerings.bicep' = {
  name: 'deploy-hub-peerings-${nowUtc}'
  scope: subscription(hubSubscriptionId)
  params: {
    hubResourceGroupName: hubResourceGroup.outputs.name
    hubVirtualNetworkName: hub.outputs.virtualNetworkName

    //identityVirtualNetworkName: identity.outputs.virtualNetworkName
    operationsVirtualNetworkName: operations.outputs.virtualNetworkName
    //sharedServicesVirtualNetworkName: sharedServices.outputs.virtualNetworkName

    // Opened Github issue: https://github.com/Azure/missionlz/issues/450
    //identityVirtualNetworkResourceId: identity.outputs.virtualNetworkResourceId
    //operationsVirtualNetworkResourceId: sharedServices.outputs.virtualNetworkResourceId
    //sharedServicesVirtualNetworkResourceId: operations.outputs.virtualNetworkResourceId

    // Potential Fix
    operationsVirtualNetworkResourceId: operations.outputs.virtualNetworkResourceId
  }
}


module operationsVirtualNetworkPeering './modules/spokeNetworkPeering.bicep' = {
  name: 'deploy-operations-peerings-${nowUtc}'
  scope: subscription(operationsSubscriptionId)
  params: {
    spokeResourceGroupName: operationsResourceGroup.outputs.name
    spokeVirtualNetworkName: operations.outputs.virtualNetworkName

    hubVirtualNetworkName: hub.outputs.virtualNetworkName
    hubVirtualNetworkResourceId: hub.outputs.virtualNetworkResourceId
  }
}

module hubPolicyAssignment './modules/policyAssignment.bicep' = {
  name: 'assign-policy-hub-${nowUtc}'
  scope: resourceGroup(hubSubscriptionId, hubResourceGroupName)
  params: {
    builtInAssignment: policy
    logAnalyticsWorkspaceName: logAnalyticsWorkspace.outputs.name
    logAnalyticsWorkspaceResourceGroupName: operationsResourceGroup.outputs.name
    operationsSubscriptionId: operationsSubscriptionId
  }
}

module operationsPolicyAssignment './modules/policyAssignment.bicep' = {
  name: 'assign-policy-operations-${nowUtc}'
  scope: resourceGroup(operationsSubscriptionId, operationsResourceGroupName)
  params: {
    builtInAssignment: policy
    logAnalyticsWorkspaceName: logAnalyticsWorkspace.outputs.name
    logAnalyticsWorkspaceResourceGroupName: operationsResourceGroup.outputs.name
    operationsSubscriptionId: operationsSubscriptionId
  }
}

module hubSubscriptionCreateActivityLogging './modules/centralLogging.bicep' = {
  name: 'activity-logs-hub-${nowUtc}'
  scope: subscription(hubSubscriptionId)
  params: {
    diagnosticSettingName: 'log-hub-sub-activity-to-${logAnalyticsWorkspace.outputs.name}'
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.outputs.id
  }
}

module operationsSubscriptionCreateActivityLogging './modules/centralLogging.bicep' = if(hubSubscriptionId != operationsSubscriptionId) {
  name: 'activity-logs-operations-${nowUtc}'
  scope: subscription(operationsSubscriptionId)
  params: {
    diagnosticSettingName: 'log-operations-sub-activity-to-${logAnalyticsWorkspace.outputs.name}'
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.outputs.id
  }
}

module remoteAccess './modules/remoteAccess.bicep' = if(deployRemoteAccess) {
  name: 'deploy-remote-access-${nowUtc}'
  scope: resourceGroup(hubSubscriptionId, hubResourceGroupName)

  params: {
    location: hubLocation
    
    hubVirtualNetworkName: hub.outputs.virtualNetworkName
    hubSubnetResourceId: hub.outputs.subnetResourceId
    hubNetworkSecurityGroupResourceId: hub.outputs.networkSecurityGroupResourceId

    bastionHostName: bastionHostName
    bastionHostSubnetAddressPrefix: bastionHostSubnetAddressPrefix
    bastionHostPublicIPAddressName: bastionHostPublicIPAddressName
    bastionHostPublicIPAddressSkuName: bastionHostPublicIPAddressSkuName
    bastionHostPublicIPAddressAllocationMethod: bastionHostPublicIPAddressAllocationMethod
    bastionHostPublicIPAddressAvailabilityZones: bastionHostPublicIPAddressAvailabilityZones
    bastionHostIPConfigurationName: bastionHostIPConfigurationName

    linuxNetworkInterfaceName: linuxNetworkInterfaceName
    linuxNetworkInterfaceIpConfigurationName: linuxNetworkInterfaceIpConfigurationName
    linuxNetworkInterfacePrivateIPAddressAllocationMethod: linuxNetworkInterfacePrivateIPAddressAllocationMethod

    linuxVmName: linuxVmName
    linuxVmSize: linuxVmSize
    linuxVmOsDiskCreateOption: linuxVmOsDiskCreateOption
    linuxVmOsDiskType: linuxVmOsDiskType
    linuxVmImagePublisher: linuxVmImagePublisher
    linuxVmImageOffer: linuxVmImageOffer
    linuxVmImageSku: linuxVmImageSku
    linuxVmImageVersion: linuxVmImageVersion
    linuxVmAdminUsername: linuxVmAdminUsername
    linuxVmAuthenticationType: linuxVmAuthenticationType
    linuxVmAdminPasswordOrKey: linuxVmAdminPasswordOrKey

    windowsNetworkInterfaceName: windowsNetworkInterfaceName
    windowsNetworkInterfaceIpConfigurationName: windowsNetworkInterfaceIpConfigurationName
    windowsNetworkInterfacePrivateIPAddressAllocationMethod: windowsNetworkInterfacePrivateIPAddressAllocationMethod

    windowsVmName: windowsVmName
    windowsVmSize: windowsVmSize
    windowsVmAdminUsername: windowsVmAdminUsername
    windowsVmAdminPassword: windowsVmAdminPassword
    windowsVmPublisher: windowsVmPublisher
    windowsVmOffer: windowsVmOffer
    windowsVmSku: windowsVmSku
    windowsVmVersion: windowsVmVersion
    windowsVmCreateOption: windowsVmCreateOption
    windowsVmStorageAccountType: windowsVmStorageAccountType
  }
}

