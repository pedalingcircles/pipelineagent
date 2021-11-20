// scope
targetScope = 'subscription'

@description('Used to identify environment types for naming resources.')
@allowed([
  'ephemeral'   // Used for short lived environments used for smoke testing, PRs, feature teams, etc. 
  'sandbox'     // Used for experimental work that's not part of the promotion process.
  'integration' // The first integration environment. Typically the first environment deployed off of a trunk branch.
  'development' // The main environment used by developers and engineers to validate, debug, showcase, and collaborate on the solution being built.
  'demo'        // The demo environment. This is used to showcase to customers, the internal team, of leadership. It can optionally be used for sprint demos.
  'test'        // The funtional testing environment
  'acceptance'  // User acceptance testing (aka UAT)
  'staging'     // A mirrored or similiar version of production. Typically all settings match including SKUs and configuration 
  'production'  // The live production environment
])
param environmentType string

@description('Used to identify the type of workload.')
@maxLength(15)
param workload string = 'pipelineagent'

@description('Abbreviated values of the workload.')
@maxLength(4)
param workloadShort string = 'pa'

@description('The organization that\'s responsible for the workload.')
param organization string

@description('The timestamp for deployment names.')
param nowUtc string = utcNow()

// Variable used internally to just map long names to short names
var environmentTypeMap = {
  ephemeral: 'eph'
  sandbox: 'sbx'
  integration: 'int'
  development: 'dev'
  demo: 'dem'
  test: 'tst'
  acceptance: 'uat'
  staging: 'stg'
  production: 'prd'
}
var environmentTypeShort = environmentTypeMap[environmentType]

// Unique ID is scoped so that it can be unique enough to support multiple "environments" but 
// not unique to the deployment run. If you need to support additioanl conflic resolution with resource 
// naming then this value can be updated.
var uniqueId = uniqueString('${workloadShort}${environmentType}${organization}${subscription().subscriptionId}')

// Used as a convention when naming resources. This is generally an affix values and 
// maybe have a prefix and suffix when combined to name any resource. There is a 
// regular and short name values due to certain Azure naming restriction which
// may require shorter name.
var resourceNamePlaceholder = '${workload}[delimiterplaceholder]${environmentType}[delimiterplaceholder]${uniqueId}'
var resourceNamePlaceholderShort = '${workloadShort}[delimiterplaceholder]${environmentTypeShort}[delimiterplaceholder]${uniqueId}'

// subscription ids. They could all potentially be different
param hubSubscriptionId string = subscription().subscriptionId
param agentSubscriptionId string = subscription().subscriptionId
param imageSubscriptionId string = subscription().subscriptionId
param imageBuilderSubscriptionId string = subscription().subscriptionId
param operationsSubscriptionId string = subscription().subscriptionId
param identitySubscriptionId string = subscription().subscriptionId

// locations. They could all potentially be different
param hubLocation string = deployment().location
param agentLocation string = deployment().location
param imageBuilderLocation string = deployment().location
param imageLocation string = deployment().location
param operationsLocation string = deployment().location
param identityLocation string = deployment().location

// resource group names
var hubResourceGroupName = 'rg-${replace(resourceNamePlaceholder, '[delimiterplaceholder]', '-')}-hub'
var agentResourceGroupName = 'rg-${replace(resourceNamePlaceholder, '[delimiterplaceholder]', '-')}-agent'
var imageBuilderResourceGroupName = 'rg-${replace(resourceNamePlaceholder, '[delimiterplaceholder]', '-')}-imagebuilder'
var imageResourceGroupName = 'rg-${replace(resourceNamePlaceholder, '[delimiterplaceholder]', '-')}-image'
var operationsResourceGroupName = 'rg-${replace(resourceNamePlaceholder, '[delimiterplaceholder]', '-')}-operations'
var identityResourceGroupName ='rg-${replace(resourceNamePlaceholder, '[delimiterplaceholder]', '-')}-identity'

// Tags the the various components and resources
var defaultTags = {
  'environmentType': environmentType
  'org': organization
  'workload': workload
}
param hubTags object = {
  'component': 'hub'
}
param agentTags object = {
  'component': 'agent'
}
param imageBuilderTags object = {
  'component': 'imagebuilder'
}
param imageTags object = {
  'component': 'image'
}
param operationsTags object = {
  'component': 'operations'
}
param identityTags object = {
  'component': 'identity'
}

module hubResourceGroup './modules/resourceGroup.bicep' = {
  name: 'deploy-rg-hub-${nowUtc}'
  scope: subscription(hubSubscriptionId)
  params: {
    name: hubResourceGroupName
    location: hubLocation
    tags: union(hubTags,defaultTags)
  }
}

var spokes = [
  {
    name: 'operations'
    subscriptionId: operationsSubscriptionId
    resourceGroupName: operationsResourceGroupName
    location: operationsLocation
    logStorageAccountName: operationsLogStorageAccountName
    logStorageSkuName: operationsLogStorageSkuName
    virtualNetworkName: operationsVirtualNetworkName
    virtualNetworkAddressPrefix: operationsVirtualNetworkAddressPrefix
    virtualNetworkDiagnosticsLogs: operationsVirtualNetworkDiagnosticsLogs
    virtualNetworkDiagnosticsMetrics: operationsVirtualNetworkDiagnosticsMetrics
    networkSecurityGroupName: operationsNetworkSecurityGroupName
    networkSecurityGroupRules: operationsNetworkSecurityGroupRules
    networkSecurityGroupDiagnosticsLogs: operationsNetworkSecurityGroupDiagnosticsLogs
    networkSecurityGroupDiagnosticsMetrics: operationsNetworkSecurityGroupDiagnosticsMetrics
    subnetName: operationsSubnetName
    subnetAddressPrefix: operationsSubnetAddressPrefix
    subnetServiceEndpoints: operationsSubnetServiceEndpoints
    tags: union(operationsTags,defaultTags)
  }
  {
    name: 'agent'
    subscriptionId: agentSubscriptionId
    resourceGroupName: agentResourceGroupName
    location: agentLocation
    logStorageAccountName: agentLogStorageAccountName
    logStorageSkuName: agentLogStorageSkuName
    virtualNetworkName: agentVirtualNetworkName
    virtualNetworkAddressPrefix: agentVirtualNetworkAddressPrefix
    virtualNetworkDiagnosticsLogs: agentVirtualNetworkDiagnosticsLogs
    virtualNetworkDiagnosticsMetrics: agentVirtualNetworkDiagnosticsMetrics
    networkSecurityGroupName: agentNetworkSecurityGroupName
    networkSecurityGroupRules: agentNetworkSecurityGroupRules
    networkSecurityGroupDiagnosticsLogs: agentNetworkSecurityGroupDiagnosticsLogs
    networkSecurityGroupDiagnosticsMetrics: agentNetworkSecurityGroupDiagnosticsMetrics
    subnetName: agentSubnetName
    subnetAddressPrefix: agentSubnetAddressPrefix
    subnetServiceEndpoints: agentSubnetServiceEndpoints
    tags: union(agentTags,defaultTags)
  }
  {
    name: 'image'
    subscriptionId: imageSubscriptionId
    resourceGroupName: imageResourceGroupName
    location: imageLocation
    logStorageAccountName: imageLogStorageAccountName
    logStorageSkuName: imageLogStorageSkuName
    virtualNetworkName: imageVirtualNetworkName
    virtualNetworkAddressPrefix: imageVirtualNetworkAddressPrefix
    virtualNetworkDiagnosticsLogs: imageVirtualNetworkDiagnosticsLogs
    virtualNetworkDiagnosticsMetrics: imageVirtualNetworkDiagnosticsMetrics
    networkSecurityGroupName: imageNetworkSecurityGroupName
    networkSecurityGroupRules: imageNetworkSecurityGroupRules
    networkSecurityGroupDiagnosticsLogs: imageNetworkSecurityGroupDiagnosticsLogs
    networkSecurityGroupDiagnosticsMetrics: imageNetworkSecurityGroupDiagnosticsMetrics
    subnetName: imageSubnetName
    subnetAddressPrefix: imageSubnetAddressPrefix
    subnetServiceEndpoints: imageSubnetServiceEndpoints
    tags: union(imageTags,defaultTags)
  }
  {
    name: 'imagebuilder'
    subscriptionId: imageBuilderSubscriptionId
    resourceGroupName: imageBuilderResourceGroupName
    location: imageBuilderLocation
    logStorageAccountName: imageBuilderLogStorageAccountName
    logStorageSkuName: imageBuilderLogStorageSkuName
    virtualNetworkName: imageBuilderVirtualNetworkName
    virtualNetworkAddressPrefix: imageBuilderVirtualNetworkAddressPrefix
    virtualNetworkDiagnosticsLogs: imageBuilderVirtualNetworkDiagnosticsLogs
    virtualNetworkDiagnosticsMetrics: imageBuilderVirtualNetworkDiagnosticsMetrics
    networkSecurityGroupName: imageBuilderNetworkSecurityGroupName
    networkSecurityGroupRules: imageBuilderNetworkSecurityGroupRules
    networkSecurityGroupDiagnosticsLogs: imageBuilderNetworkSecurityGroupDiagnosticsLogs
    networkSecurityGroupDiagnosticsMetrics: imageBuilderNetworkSecurityGroupDiagnosticsMetrics
    subnetName: imageBuilderSubnetName
    subnetAddressPrefix: imageBuilderSubnetAddressPrefix
    subnetServiceEndpoints: imageBuilderSubnetServiceEndpoints
    tags: union(imageBuilderTags,defaultTags)
  }
  {
    name: 'identity'
    subscriptionId: identitySubscriptionId
    resourceGroupName: identityResourceGroupName
    location: identityLocation
    logStorageAccountName: identityLogStorageAccountName
    logStorageSkuName: identityLogStorageSkuName
    virtualNetworkName: identityVirtualNetworkName
    virtualNetworkAddressPrefix: identityVirtualNetworkAddressPrefix
    virtualNetworkDiagnosticsLogs: identityVirtualNetworkDiagnosticsLogs
    virtualNetworkDiagnosticsMetrics: identityVirtualNetworkDiagnosticsMetrics
    networkSecurityGroupName: identityNetworkSecurityGroupName
    networkSecurityGroupRules: identityNetworkSecurityGroupRules
    networkSecurityGroupDiagnosticsLogs: identityNetworkSecurityGroupDiagnosticsLogs
    networkSecurityGroupDiagnosticsMetrics: identityNetworkSecurityGroupDiagnosticsMetrics
    subnetName: identitySubnetName
    subnetAddressPrefix: identitySubnetAddressPrefix
    subnetServiceEndpoints: identitySubnetServiceEndpoints
    tags: union(identityTags,defaultTags)

  }
]

module spokeResourceGroups './modules/resourceGroup.bicep' = [for spoke in spokes: {
  name: 'deploy-rg-${spoke.name}-${nowUtc}'
  scope: subscription(spoke.subscriptionId)
  params: {
    name: spoke.resourceGroupName
    location: spoke.location
    tags: spoke.tags
  }
}]






// Log analytics workspace settings
param logAnalyticsWorkspaceRetentionInDays int = 30
param logAnalyticsWorkspaceSkuName string = 'PerGB2018'
param logAnalyticsWorkspaceCappingDailyQuotaGb int = -1

@description('When set to "True", enables Microsoft Sentinel within the ADO Agent pipelines Log Analytics workspace.')
param deploySentinel bool = false

var sharedImageGalleryName = take('sig.${replace(resourceNamePlaceholderShort, '[delimiterplaceholder]', '.')}', 80)

// taking 63 minus the literal characters (15) = 48
var logAnalyticsWorkspaceName = take('log-operations-${replace(resourceNamePlaceholderShort, '[delimiterplaceholder]', '-')}', 63)

// hub networking
var hubLogStorageAccountName = take('sthublogs${replace(resourceNamePlaceholderShort, '[delimiterplaceholder]', '')}', 24)
param hubLogStorageSkuName string = 'Standard_GRS'
param hubVirtualNetworkName string = 'vnet-hub'
param hubVirtualNetworkAddressPrefix string = '10.0.100.0/24'
param hubVirtualNetworkDiagnosticsLogs array = []
param hubVirtualNetworkDiagnosticsMetrics array = []
param hubNetworkSecurityGroupName string = 'nsg-hub'
param hubNetworkSecurityGroupRules array = []
param hubNetworkSecurityGroupDiagnosticsLogs array = [
  {
    category: 'NetworkSecurityGroupEvent'
    enabled: true
  }
  {
    category: 'NetworkSecurityGroupRuleCounter'
    enabled: true
  }
]
param hubNetworkSecurityGroupDiagnosticsMetrics array = []
param hubSubnetName string = 'snet-hub'
param hubSubnetAddressPrefix string = '10.0.100.128/27'
param hubSubnetServiceEndpoints array = []

param firewallSkuTier string = 'Premium'
param firewallName string = 'firewall'
param firewallManagementSubnetAddressPrefix string = '10.0.100.64/26'
param firewallClientSubnetAddressPrefix string = '10.0.100.0/26'
param firewallPolicyName string = 'firewall-policy'
param firewallThreatIntelMode string = 'Alert'
param firewallDiagnosticsLogs array = [
  {
    category: 'AzureFirewallApplicationRule'
    enabled: true
  }
  {
    category: 'AzureFirewallNetworkRule'
    enabled: true
  }
  {
    category: 'AzureFirewallDnsProxy'
    enabled: true
  }
]
param firewallDiagnosticsMetrics array = [
  {
    category: 'AllMetrics'
    enabled: true
  }
]
var firewallClientSubnetName = 'AzureFirewallSubnet' //this must be 'AzureFirewallSubnet'
param firewallClientIpConfigurationName string = 'firewall-client-ip-config'
param firewallClientSubnetServiceEndpoints array = []
param firewallClientPublicIPAddressName string = 'firewall-client-public-ip'
param firewallClientPublicIPAddressSkuName string = 'Standard'
param firewallClientPublicIpAllocationMethod string = 'Static'
param firewallClientPublicIPAddressAvailabilityZones array = []
var firewallManagementSubnetName = 'AzureFirewallManagementSubnet' //this must be 'AzureFirewallManagementSubnet'
param firewallManagementIpConfigurationName string = 'firewall-management-ip-config'
param firewallManagementSubnetServiceEndpoints array = []
param firewallManagementPublicIPAddressName string = 'firewall-management-public-ip'
param firewallManagementPublicIPAddressSkuName string = 'Standard'
param firewallManagementPublicIpAllocationMethod string = 'Static'
param firewallManagementPublicIPAddressAvailabilityZones array = []
param publicIPAddressDiagnosticsLogs array = [
  {
    category: 'DDoSProtectionNotifications'
    enabled: true
  }
  {
    category: 'DDoSMitigationFlowLogs'
    enabled: true
  }
  {
    category: 'DDoSMitigationReports'
    enabled: true
  }
]
param publicIPAddressDiagnosticsMetrics array = [
  {
    category: 'AllMetrics'
    enabled: true
  }
]




var operationsLogStorageAccountName = take('stopslogs${replace(resourceNamePlaceholderShort, '[delimiterplaceholder]', '')}', 24)
param operationsLogStorageSkuName string = hubLogStorageSkuName
param operationsVirtualNetworkName string = replace(hubVirtualNetworkName, 'hub', 'operations')
param operationsVirtualNetworkAddressPrefix string = '10.0.115.0/26'
param operationsVirtualNetworkDiagnosticsLogs array = []
param operationsVirtualNetworkDiagnosticsMetrics array = []
param operationsNetworkSecurityGroupName string = replace(hubNetworkSecurityGroupName, 'hub', 'operations')
param operationsNetworkSecurityGroupDiagnosticsLogs array = hubNetworkSecurityGroupDiagnosticsLogs
param operationsNetworkSecurityGroupDiagnosticsMetrics array = hubNetworkSecurityGroupDiagnosticsMetrics
param operationsNetworkSecurityGroupRules array = []


param operationsSubnetName string = replace(hubSubnetName, 'hub', 'operations')
param operationsSubnetAddressPrefix string = '10.0.115.0/27'
param operationsSubnetServiceEndpoints array = []

// image spoke networking
var imageLogStorageAccountName = take('stimage${replace(resourceNamePlaceholderShort, '[delimiterplaceholder]', '')}', 24)
param imageLogStorageSkuName string = hubLogStorageSkuName
param imageVirtualNetworkName string = replace(hubVirtualNetworkName, 'hub', 'image')
param imageVirtualNetworkAddressPrefix string = '10.0.120.0/26'
param imageVirtualNetworkDiagnosticsLogs array = []
param imageVirtualNetworkDiagnosticsMetrics array = []
param imageNetworkSecurityGroupName string = replace(hubNetworkSecurityGroupName, 'hub', 'image')
param imageNetworkSecurityGroupDiagnosticsLogs array = hubNetworkSecurityGroupDiagnosticsLogs
param imageNetworkSecurityGroupDiagnosticsMetrics array = hubNetworkSecurityGroupDiagnosticsMetrics
param imageNetworkSecurityGroupRules array = []
param imageSubnetName string = replace(hubSubnetName, 'hub', 'packer')
param imageSubnetAddressPrefix string = '10.0.120.0/28'
param imageSubnetServiceEndpoints array = []

// agent spoke networking
var agentLogStorageAccountName = take('stagent${replace(resourceNamePlaceholderShort, '[delimiterplaceholder]', '')}', 24)
param agentLogStorageSkuName string = hubLogStorageSkuName
param agentVirtualNetworkName string = replace(hubVirtualNetworkName, 'hub', 'agent')
param agentVirtualNetworkAddressPrefix string = '10.1.0.0/16'
param agentVirtualNetworkDiagnosticsLogs array = []
param agentVirtualNetworkDiagnosticsMetrics array = []
param agentNetworkSecurityGroupName string = replace(hubNetworkSecurityGroupName, 'hub', 'agent')
param agentNetworkSecurityGroupDiagnosticsLogs array = hubNetworkSecurityGroupDiagnosticsLogs
param agentNetworkSecurityGroupDiagnosticsMetrics array = hubNetworkSecurityGroupDiagnosticsMetrics
param agentNetworkSecurityGroupRules array = []
param agentSubnetName string = replace(hubSubnetName, 'hub', 'agent')
param agentSubnetAddressPrefix string = '10.1.100.0/24'
param agentSubnetServiceEndpoints array = []

// imagebuilding spoke networking
var imageBuilderLogStorageAccountName = take('stimgbldr${replace(resourceNamePlaceholderShort, '[delimiterplaceholder]', '')}', 24)
param imageBuilderLogStorageSkuName string = hubLogStorageSkuName
param imageBuilderVirtualNetworkName string = replace(hubVirtualNetworkName, 'hub', 'imagebuilder')
param imageBuilderVirtualNetworkAddressPrefix string = '10.0.130.0/24'
param imageBuilderVirtualNetworkDiagnosticsLogs array = []
param imageBuilderVirtualNetworkDiagnosticsMetrics array = []
param imageBuilderNetworkSecurityGroupName string = replace(hubNetworkSecurityGroupName, 'hub', 'imagebuilder')
param imageBuilderNetworkSecurityGroupDiagnosticsLogs array = hubNetworkSecurityGroupDiagnosticsLogs
param imageBuilderNetworkSecurityGroupDiagnosticsMetrics array = hubNetworkSecurityGroupDiagnosticsMetrics
param imageBuilderNetworkSecurityGroupRules array = []
param imageBuilderSubnetName string = replace(hubSubnetName, 'hub', 'imagebuilder')
param imageBuilderSubnetAddressPrefix string = '10.0.130.0/25'
param imageBuilderSubnetServiceEndpoints array = []

// identity spoke networking
var identityLogStorageAccountName = take('stimgbldr${replace(resourceNamePlaceholderShort, '[delimiterplaceholder]', '')}', 24)
param identityLogStorageSkuName string = hubLogStorageSkuName
param identityVirtualNetworkName string = replace(hubVirtualNetworkName, 'hub', 'identity')
param identityVirtualNetworkAddressPrefix string = '10.0.130.0/24'
param identityVirtualNetworkDiagnosticsLogs array = []
param identityVirtualNetworkDiagnosticsMetrics array = []
param identityNetworkSecurityGroupName string = replace(hubNetworkSecurityGroupName, 'hub', 'identity')
param identityNetworkSecurityGroupDiagnosticsLogs array = hubNetworkSecurityGroupDiagnosticsLogs
param identityNetworkSecurityGroupDiagnosticsMetrics array = hubNetworkSecurityGroupDiagnosticsMetrics
param identityNetworkSecurityGroupRules array = []
param identitySubnetName string = replace(hubSubnetName, 'hub', 'identity')
param identitySubnetAddressPrefix string = '10.0.130.0/25'
param identitySubnetServiceEndpoints array = []

@allowed([
  'NIST'
  'IL5' // Gov cloud only, trying to deploy IL5 in AzureCloud will switch to NIST
  'CMMC'
])
@description('Built-in policy assignments to assign, default is none. [NIST/IL5/CMMC] IL5 is only availalbe for GOV cloud and will switch to NIST if tried in AzureCloud.')
param policy string = 'NIST'

param deployPolicy bool = false

@description('Email address of the contact, in the form of john@doe.com')
param emailSecurityContact string = ''

param deployASC bool = false


// Key vault deployment not currently working
param deployAgentKeyVault bool = false

param bastionHostName string = 'bastionHost'
param bastionHostSubnetAddressPrefix string = '10.0.100.160/27'
param bastionHostPublicIPAddressName string = 'bastionHostPublicIPAddress'
param bastionHostPublicIPAddressSkuName string = 'Standard'
param bastionHostPublicIPAddressAllocationMethod string = 'Static'
param bastionHostPublicIPAddressAvailabilityZones array = []
param bastionHostIPConfigurationName string = 'bastionHostIPConfiguration'


var agentKeyVaultName = take('kv-${replace(resourceNamePlaceholderShort, '[delimiterplaceholder]', '-')}', 24)




































module logAnalyticsWorkspace './modules/logAnalyticsWorkspace.bicep' = {
  name: 'deploy-laws-${nowUtc}'
  scope: resourceGroup(operationsSubscriptionId, operationsResourceGroupName)
  params: {
    name: logAnalyticsWorkspaceName
    location: operationsLocation
    tags: union(operationsTags,defaultTags)
    deploySentinel: deploySentinel
    retentionInDays: logAnalyticsWorkspaceRetentionInDays
    skuName: logAnalyticsWorkspaceSkuName
    workspaceCappingDailyQuotaGb: logAnalyticsWorkspaceCappingDailyQuotaGb
  }
  dependsOn: [
    spokeResourceGroups
  ]
}

module hubNetwork './modules/hubNetwork.bicep' = {
  name: 'deploy-vnet-hub-${nowUtc}'
  scope: resourceGroup(hubSubscriptionId, hubResourceGroupName)
  params: {
    location: hubLocation
    tags: hubTags

    logStorageAccountName: hubLogStorageAccountName
    logStorageSkuName: hubLogStorageSkuName

    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspace.outputs.id

    virtualNetworkName: hubVirtualNetworkName
    virtualNetworkAddressPrefix: hubVirtualNetworkAddressPrefix
    virtualNetworkDiagnosticsLogs: hubVirtualNetworkDiagnosticsLogs
    virtualNetworkDiagnosticsMetrics: hubVirtualNetworkDiagnosticsMetrics

    networkSecurityGroupName: hubNetworkSecurityGroupName
    networkSecurityGroupRules: hubNetworkSecurityGroupRules
    networkSecurityGroupDiagnosticsLogs: hubNetworkSecurityGroupDiagnosticsLogs
    networkSecurityGroupDiagnosticsMetrics: hubNetworkSecurityGroupDiagnosticsMetrics

    subnetName: hubSubnetName
    subnetAddressPrefix: hubSubnetAddressPrefix
    subnetServiceEndpoints: hubSubnetServiceEndpoints

    firewallName: firewallName
    firewallSkuTier: firewallSkuTier
    firewallPolicyName: firewallPolicyName
    firewallThreatIntelMode: firewallThreatIntelMode
    firewallDiagnosticsLogs: firewallDiagnosticsLogs
    firewallDiagnosticsMetrics: firewallDiagnosticsMetrics
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

    bastionHostName: bastionHostName
    bastionHostSubnetAddressPrefix: bastionHostSubnetAddressPrefix
    bastionHostPublicIPAddressName: bastionHostPublicIPAddressName
    bastionHostPublicIPAddressSkuName: bastionHostPublicIPAddressSkuName
    bastionHostPublicIPAddressAllocationMethod: bastionHostPublicIPAddressAllocationMethod
    bastionHostPublicIPAddressAvailabilityZones: bastionHostPublicIPAddressAvailabilityZones
    bastionHostIPConfigurationName: bastionHostIPConfigurationName

    publicIPAddressDiagnosticsLogs: publicIPAddressDiagnosticsLogs
    publicIPAddressDiagnosticsMetrics: publicIPAddressDiagnosticsMetrics
  }
}

module spokeNetworks './modules/spokeNetwork.bicep' = [ for spoke in spokes: {
  name: 'deploy-vnet-${spoke.name}-${nowUtc}'
  scope: resourceGroup(spoke.subscriptionId, spoke.resourceGroupName)
  params: {
    location: spoke.location
    tags: spoke.tags

    logStorageAccountName: spoke.logStorageAccountName
    logStorageSkuName: spoke.logStorageSkuName

    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspace.outputs.id

    firewallPrivateIPAddress: hubNetwork.outputs.firewallPrivateIPAddress

    virtualNetworkName: spoke.virtualNetworkName
    virtualNetworkAddressPrefix: spoke.virtualNetworkAddressPrefix
    virtualNetworkDiagnosticsLogs: spoke.virtualNetworkDiagnosticsLogs
    virtualNetworkDiagnosticsMetrics: spoke.virtualNetworkDiagnosticsMetrics

    networkSecurityGroupName: spoke.networkSecurityGroupName
    networkSecurityGroupRules: spoke.networkSecurityGroupRules
    networkSecurityGroupDiagnosticsLogs: spoke.networkSecurityGroupDiagnosticsLogs
    networkSecurityGroupDiagnosticsMetrics: spoke.networkSecurityGroupDiagnosticsMetrics

    subnetName: spoke.subnetName
    subnetAddressPrefix: spoke.subnetAddressPrefix
    subnetServiceEndpoints: spoke.subnetServiceEndpoints
  }
}]

module hubVirtualNetworkPeerings './modules/hubNetworkPeerings.bicep' = {
  name: 'deploy-vnet-peerings-hub-${nowUtc}'
  scope: resourceGroup(hubSubscriptionId, hubResourceGroupName)
  params: {
    hubVirtualNetworkName: hubNetwork.outputs.virtualNetworkName
    spokes: [ for (spoke, i) in spokes: {
      type: spoke.name
      virtualNetworkName: spokeNetworks[i].outputs.virtualNetworkName
      virtualNetworkResourceId: spokeNetworks[i].outputs.virtualNetworkResourceId
    }]
  }
}

module spokeVirtualNetworkPeerings './modules/spokeNetworkPeering.bicep' = [ for (spoke, i) in spokes: {
  name: 'deploy-vnet-peerings-${spoke.name}-${nowUtc}'
  scope: subscription(spoke.subscriptionId)
  params: {
    spokeName: spoke.name
    spokeResourceGroupName: spoke.resourceGroupName
    spokeVirtualNetworkName: spokeNetworks[i].outputs.virtualNetworkName
    hubVirtualNetworkName: hubNetwork.outputs.virtualNetworkName
    hubVirtualNetworkResourceId: hubNetwork.outputs.virtualNetworkResourceId
  }
}]

module hubPolicyAssignment './modules/policyAssignment.bicep' = {
  name: 'assign-policy-hub-${nowUtc}'
  scope: resourceGroup(hubSubscriptionId, hubResourceGroupName)
  params: {
    builtInAssignment: policy
    logAnalyticsWorkspaceName: logAnalyticsWorkspace.outputs.name
    logAnalyticsWorkspaceResourceGroupName: logAnalyticsWorkspace.outputs.name
    operationsSubscriptionId: operationsSubscriptionId
  }
}

module spokePolicyAssignments './modules/policyAssignment.bicep' = [ for spoke in spokes: if(deployPolicy) {
  name: 'assign-policy-${spoke.name}-${nowUtc}'
  scope: resourceGroup(spoke.subscriptionId, spoke.resourceGroupName)
  params: {
    builtInAssignment: policy
    logAnalyticsWorkspaceName: logAnalyticsWorkspace.outputs.name
    logAnalyticsWorkspaceResourceGroupName: logAnalyticsWorkspace.outputs.resourceGroupName
    operationsSubscriptionId: operationsSubscriptionId
  }
}]

module hubSubscriptionActivityLogging './modules/centralLogging.bicep' = {
  name: 'activity-logs-hub-${nowUtc}'
  scope: subscription(hubSubscriptionId)
  params: {
    diagnosticSettingName: 'log-hub-sub-activity-to-${logAnalyticsWorkspace.outputs.name}'
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.outputs.id
  }
  dependsOn: [
    hubNetwork
  ]
}

module spokeSubscriptionActivityLogging './modules/centralLogging.bicep' = [ for spoke in spokes: if(spoke.subscriptionId != hubSubscriptionId) {
  name: 'activity-logs-${spoke.name}-${nowUtc}'
  scope: subscription(spoke.subscriptionId)
  params: {
    diagnosticSettingName: 'log-${spoke.name}-sub-activity-to-${logAnalyticsWorkspace.outputs.name}'
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.outputs.id
  }
  dependsOn: [
    spokeNetworks
  ]
}]

module logAnalyticsDiagnosticLogging './modules/logAnalyticsDiagnosticLogging.bicep' = {
  name: 'deploy-diagnostic-logging-LAWS'
  scope: resourceGroup(operationsSubscriptionId, operationsResourceGroupName)
  params: {
    diagnosticStorageAccountName: operationsLogStorageAccountName
    logAnalyticsWorkspaceName: logAnalyticsWorkspace.outputs.name
  }
  dependsOn: [
    hubNetwork
    spokeNetworks
  ]
}

// security center per subscription if different per hub/spoke

module hubSecurityCenter './modules/securityCenter.bicep' = if(deployASC) {
  name: 'set-hub-sub-security-center'
  scope: subscription(hubSubscriptionId)
  params: {
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.outputs.id
    emailSecurityContact: emailSecurityContact
  }
}

module spokeSecurityCenter './modules/securityCenter.bicep' = [ for spoke in spokes: if( (deployASC) && (spoke.subscriptionId != hubSubscriptionId) ) {
  name: 'set-${spoke.name}-sub-security-center'
  scope: subscription(operationsSubscriptionId)
  params: {
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.outputs.id
    emailSecurityContact: emailSecurityContact
  }
}]

module sharedImageGallery './modules/sharedImageGallery.bicep' = {
  name: 'deploy-sharedimagegallery-${nowUtc}'
  scope: resourceGroup(imageSubscriptionId, imageResourceGroupName)
  params: {
    name: sharedImageGalleryName
    location: imageLocation
    tags: imageTags
  }
  dependsOn: [
    spokeNetworks
  ]
}

module agentKeyVault './modules/keyVault.bicep' = if(deployAgentKeyVault) {
  name: 'deploy-agent-keyvault-${nowUtc}'
  scope: resourceGroup(agentSubscriptionId, agentResourceGroupName)
  params: {
    name: agentKeyVaultName
    location: agentLocation
    tags: agentTags
    keyVaultAccessPolicies: []
    existingVnetName: agentVirtualNetworkName
    existingSubnetName: agentSubnetName
    tenantId: subscription().tenantId
  }
  dependsOn: [
    spokeNetworks
  ]
}

// outputs

output firewallPrivateIPAddress string = hubNetwork.outputs.firewallPrivateIPAddress

output hub object = {
  subscriptionId: hubSubscriptionId
  resourceGroupName: hubResourceGroup.outputs.name
  resourceGroupResourceId: hubResourceGroup.outputs.id
  virtualNetworkName: hubNetwork.outputs.virtualNetworkName
  virtualNetworkResourceId: hubNetwork.outputs.virtualNetworkResourceId
  subnetName: hubNetwork.outputs.subnetName
  subnetResourceId: hubNetwork.outputs.subnetResourceId
  subnetAddressPrefix: hubNetwork.outputs.subnetAddressPrefix
  networkSecurityGroupName: hubNetwork.outputs.networkSecurityGroupName
  networkSecurityGroupResourceId: hubNetwork.outputs.networkSecurityGroupResourceId
}

output logAnalyticsWorkspaceName string = logAnalyticsWorkspace.outputs.name

output logAnalyticsWorkspaceResourceId string = logAnalyticsWorkspace.outputs.id

output spokes array = [for (spoke, i) in spokes: {
  name: spoke.name
  subscriptionId: spoke.subscriptionId
  resourceGroupName: spokeResourceGroups[i].outputs.name
  resourceGroupId: spokeResourceGroups[i].outputs.id
  virtualNetworkName: spokeNetworks[i].outputs.virtualNetworkName
  virtualNetworkResourceId: spokeNetworks[i].outputs.virtualNetworkResourceId
  subnetName: spokeNetworks[i].outputs.subnetName
  subnetResourceId: spokeNetworks[i].outputs.subnetResourceId
  subnetAddressPrefix: spokeNetworks[i].outputs.subnetAddressPrefix
  networkSecurityGroupName: spokeNetworks[i].outputs.networkSecurityGroupName
  networkSecurityGroupResourceId: spokeNetworks[i].outputs.networkSecurityGroupResourceId
}]
