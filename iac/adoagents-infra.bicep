// scope
targetScope = 'subscription'

@description('Used to identify environment types for naming resources.')
@allowed([
  'ephemeral'   // Short lived environments used for smoke testing and PR approvals
  'sandbox'     // Used for experimental work and it not part of the promotion process
  'integration' // The first integration environment. Typically the first environment deployed off of the trunk branch.
  'development' // The main environment used by developers and engineers to validate, debug, showcase, and collaborate on the solution.
  'demo'        // The demo environment. This is used to showcase to customers, the internal team, of leadership. It can optionally be used for sprint demos.
  'test'        // The funtional testing environment
  'acceptance'  // User acceptance testing (aka UAT)
  'staging'     // A mirroried or similiar version of production. Typically all settings match including SKUs and configuration 
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
var uniqueId = uniqueString('${workloadShort}${environmentType}${organization}${subscription().subscriptionId}')
var resourceNamePlaceholder = '${workload}[delimiterplaceholder]${environmentType}[delimiterplaceholder]${uniqueId}'
var resourceNamePlaceholderShort = '${workloadShort}[delimiterplaceholder]${environmentTypeShort}[delimiterplaceholder]${uniqueId}'

// resource group names
var hubResourceGroupName = 'rg-${replace(resourceNamePlaceholder, '[delimiterplaceholder]', '-')}-hub'
var agentResourceGroupName = 'rg-${replace(resourceNamePlaceholder, '[delimiterplaceholder]', '-')}-agent'
var imageBuilderResourceGroupName = 'rg-${replace(resourceNamePlaceholder, '[delimiterplaceholder]', '-')}-imagebuilder'
var imageResourceGroupName = 'rg-${replace(resourceNamePlaceholder, '[delimiterplaceholder]', '-')}-image'
var operationsResourceGroupName = 'rg-${replace(resourceNamePlaceholder, '[delimiterplaceholder]', '-')}-operations'

// subscription ids. They could all potentially be different
param hubSubscriptionId string = subscription().subscriptionId
param agentSubscriptionId string = subscription().subscriptionId
param imageBuilderubscriptionId string = subscription().subscriptionId
param imageSubscriptionId string = subscription().subscriptionId
param operationsSubscriptionId string = subscription().subscriptionId

// locations. They could all potentially be different
param hubLocation string = deployment().location
param agentLocation string = deployment().location
param imageBuilderLocation string = deployment().location
param imageLocation string = deployment().location
param operationsLocation string = deployment().location

// Log analytics workspace settings
param logAnalyticsWorkspaceRetentionInDays int = 30
param logAnalyticsWorkspaceSkuName string = 'PerGB2018'
param logAnalyticsWorkspaceCappingDailyQuotaGb int = -1

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
param hubSubnetName string = 'snet-hub'
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

var operationsLogStorageAccountName = take('stopslogs${replace(resourceNamePlaceholderShort, '[delimiterplaceholder]', '')}', 24)
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

// image spoke networking
var imageLogStorageAccountName = take('stimage${replace(resourceNamePlaceholderShort, '[delimiterplaceholder]', '')}', 24)
param imageLogStorageSkuName string = hubLogStorageSkuName
param imageVirtualNetworkName string = replace(hubVirtualNetworkName, 'hub', 'image')
param imageVirtualNetworkAddressPrefix string = '10.0.120.0/26'
param imageVirtualNetworkDiagnosticsLogs array = []
param imageVirtualNetworkDiagnosticsMetrics array = []
param imageNetworkSecurityGroupName string = replace(hubNetworkSecurityGroupName, 'hub', 'image')
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
param agentNetworkSecurityGroupRules array = []
param agentSubnetName string = replace(hubSubnetName, 'hub', 'agent')
param agentSubnetAddressPrefix string = '10.1.100.0/24'
param agentSubnetServiceEndpoints array = []

@allowed([
  'NIST'
  'IL5' // Gov cloud only, trying to deploy IL5 in AzureCloud will switch to NIST
  'CMMC'
  ''
])
@description('Built-in policy assignments to assign, default is none. [NIST/IL5/CMMC] IL5 is only availalbe for GOV cloud and will switch to NIST if tried in AzureCloud.')
param policy string = ''

// Key vault deployment not currently working
param deployAgentKeyVault bool = false

param bastionHostName string = 'bastionHost'
param bastionHostSubnetAddressPrefix string = '10.0.100.160/27'
param bastionHostPublicIPAddressName string = 'bastionHostPublicIPAddress'
param bastionHostPublicIPAddressSkuName string = 'Standard'
param bastionHostPublicIPAddressAllocationMethod string = 'Static'
param bastionHostPublicIPAddressAvailabilityZones array = []
param bastionHostIPConfigurationName string = 'bastionHostIPConfiguration'
param hubTags object = {
  'environmentType': environmentType
  'org': organization
  'workload': workload
  'component': 'hub'
}
param agentTags object = {
  'environmentType': environmentType
  'org': organization
  'workload': workload
  'component': 'agent'
}
param imageBuilderTags object = {
  'environmentType': environmentType
  'org': organization
  'workload': workload
  'component': 'imagebuilder'
}
param imageTags object = {
  'environmentType': environmentType
  'org': organization
  'workload': workload
  'component': 'image'
}
param operationsTags object = {
  'environmentType': environmentType
  'org': organization
  'workload': workload
  'component': 'operations'
}

var agentKeyVaultName = take('kv-${replace(resourceNamePlaceholderShort, '[delimiterplaceholder]', '-')}', 24)


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

    bastionHostName: bastionHostName
    bastionHostSubnetAddressPrefix: bastionHostSubnetAddressPrefix
    bastionHostPublicIPAddressName: bastionHostPublicIPAddressName
    bastionHostPublicIPAddressSkuName: bastionHostPublicIPAddressSkuName
    bastionHostPublicIPAddressAllocationMethod: bastionHostPublicIPAddressAllocationMethod
    bastionHostPublicIPAddressAvailabilityZones: bastionHostPublicIPAddressAvailabilityZones
    bastionHostIPConfigurationName: bastionHostIPConfigurationName
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

// agent spoke
module agent './modules/spokeNetwork.bicep' = {
  name: 'deploy-agent-spoke-${nowUtc}'
  scope: resourceGroup(agentSubscriptionId, agentResourceGroupName)
  params: {
    location: agentLocation
    tags: agentTags

    logStorageAccountName: agentLogStorageAccountName
    logStorageSkuName: agentLogStorageSkuName

    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspace.outputs.id

    firewallPrivateIPAddress: hub.outputs.firewallPrivateIPAddress

    virtualNetworkName: agentVirtualNetworkName
    virtualNetworkAddressPrefix: agentVirtualNetworkAddressPrefix
    virtualNetworkDiagnosticsLogs: agentVirtualNetworkDiagnosticsLogs
    virtualNetworkDiagnosticsMetrics: agentVirtualNetworkDiagnosticsMetrics

    networkSecurityGroupName: agentNetworkSecurityGroupName
    networkSecurityGroupRules: agentNetworkSecurityGroupRules

    subnetName: agentSubnetName
    subnetAddressPrefix: agentSubnetAddressPrefix
    subnetServiceEndpoints: agentSubnetServiceEndpoints
  }
}

module image './modules/spokeNetwork.bicep' = {
  name: 'deploy-image-spoke-${nowUtc}'
  scope: resourceGroup(imageSubscriptionId, imageResourceGroupName)
  params: {
    location: imageLocation
    tags: imageTags

    logStorageAccountName: imageLogStorageAccountName
    logStorageSkuName: imageLogStorageSkuName

    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspace.outputs.id

    firewallPrivateIPAddress: hub.outputs.firewallPrivateIPAddress

    virtualNetworkName: imageVirtualNetworkName
    virtualNetworkAddressPrefix: imageVirtualNetworkAddressPrefix
    virtualNetworkDiagnosticsLogs: imageVirtualNetworkDiagnosticsLogs
    virtualNetworkDiagnosticsMetrics: imageVirtualNetworkDiagnosticsMetrics

    networkSecurityGroupName: imageNetworkSecurityGroupName
    networkSecurityGroupRules: imageNetworkSecurityGroupRules

    subnetName: imageSubnetName
    subnetAddressPrefix: imageSubnetAddressPrefix
    subnetServiceEndpoints: imageSubnetServiceEndpoints
  }
}

module hubVirtualNetworkPeerings './modules/hubNetworkPeerings.bicep' = {
  name: 'deploy-hub-peerings-${nowUtc}'
  scope: subscription(hubSubscriptionId)
  params: {
    hubResourceGroupName: hubResourceGroup.outputs.name
    hubVirtualNetworkName: hub.outputs.virtualNetworkName
    imageVirtualNetworkName: image.outputs.virtualNetworkName
    imageVirtualNetworkResourceId: image.outputs.virtualNetworkResourceId
    agentVirtualNetworkName: agent.outputs.virtualNetworkName
    agentVirtualNetworkResourceId: agent.outputs.virtualNetworkResourceId
    operationsVirtualNetworkName: operations.outputs.virtualNetworkName
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

module agentVirtualNetworkPeering './modules/spokeNetworkPeering.bicep' = {
  name: 'deploy-agent-peerings-${nowUtc}'
  scope: subscription(agentSubscriptionId)
  params: {
    spokeResourceGroupName: agentResourceGroup.outputs.name
    spokeVirtualNetworkName: agent.outputs.virtualNetworkName

    hubVirtualNetworkName: hub.outputs.virtualNetworkName
    hubVirtualNetworkResourceId: hub.outputs.virtualNetworkResourceId
  }
}

module imageVirtualNetworkPeering './modules/spokeNetworkPeering.bicep' = {
  name: 'deploy-image-peerings-${nowUtc}'
  scope: subscription(imageSubscriptionId)
  params: {
    spokeResourceGroupName: imageResourceGroup.outputs.name
    spokeVirtualNetworkName: image.outputs.virtualNetworkName

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

module agentPolicyAssignment './modules/policyAssignment.bicep' = {
  name: 'assign-policy-agent-${nowUtc}'
  scope: resourceGroup(agentSubscriptionId, agentResourceGroupName)
  params: {
    builtInAssignment: policy
    logAnalyticsWorkspaceName: logAnalyticsWorkspace.outputs.name
    logAnalyticsWorkspaceResourceGroupName: operationsResourceGroup.outputs.name
    operationsSubscriptionId: operationsSubscriptionId
  }
}

module imagePolicyAssignment './modules/policyAssignment.bicep' = {
  name: 'assign-policy-image-${nowUtc}'
  scope: resourceGroup(imageSubscriptionId, imageResourceGroupName)
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

module agentSubscriptionCreateActivityLogging './modules/centralLogging.bicep' = if(hubSubscriptionId != agentSubscriptionId) {
  name: 'activity-logs-agent-${nowUtc}'
  scope: subscription(agentSubscriptionId)
  params: {
    diagnosticSettingName: 'log-agent-sub-activity-to-${logAnalyticsWorkspace.outputs.name}'
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.outputs.id
  }
}

module imageSubscriptionCreateActivityLogging './modules/centralLogging.bicep' = if(hubSubscriptionId != imageSubscriptionId) {
  name: 'activity-logs-image-${nowUtc}'
  scope: subscription(imageSubscriptionId)
  params: {
    diagnosticSettingName: 'log-image-sub-activity-to-${logAnalyticsWorkspace.outputs.name}'
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.outputs.id
  }
}

module sharedImageGallery './modules/sharedImageGallery.bicep' = {
  name: 'deploy-sharedimagegallery-${nowUtc}'
  scope: resourceGroup(imageSubscriptionId, imageResourceGroupName)
  params: {
    name: sharedImageGalleryName
    location: imageLocation
    tags: imageTags
  }
  dependsOn: [
    imageResourceGroup
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
    agentResourceGroup
  ]
}

// outputs
output hubSubscriptionId string = hubSubscriptionId
output hubResourceGroupName string = hubResourceGroup.outputs.name
output hubResourceGroupResourceId string = hubResourceGroup.outputs.id
output hubVirtualNetworkName string = hub.outputs.virtualNetworkName
output hubVirtualNetworkResourceId string = hub.outputs.virtualNetworkResourceId
output hubSubnetName string = hub.outputs.subnetName
output hubSubnetResourceId string = hub.outputs.subnetResourceId
output hubSubnetAddressPrefix string = hub.outputs.subnetAddressPrefix
output hubNetworkSecurityGroupName string = hub.outputs.networkSecurityGroupName
output hubNetworkSecurityGroupResourceId string = hub.outputs.networkSecurityGroupResourceId
output hubFirewallPrivateIPAddress string = hub.outputs.firewallPrivateIPAddress

output logAnalyticsWorkspaceName string = logAnalyticsWorkspace.outputs.name
output logAnalyticsWorkspaceResourceId string = logAnalyticsWorkspace.outputs.id
output firewallPrivateIPAddress string = hub.outputs.firewallPrivateIPAddress

output operationsSubscriptionId string = operationsSubscriptionId
output operationsResourceGroupName string = operationsResourceGroup.outputs.name
output operationsResourceGroupResourceId string = operationsResourceGroup.outputs.id
output operationsVirtualNetworkName string = operations.outputs.virtualNetworkName
output operationsVirtualNetworkResourceId string = operations.outputs.virtualNetworkResourceId
output operationsSubnetName string = operations.outputs.subnetName
output operationsSubnetResourceId string = operations.outputs.subnetResourceId
output operationsSubnetAddressPrefix string = operations.outputs.subnetAddressPrefix
output operationsNetworkSecurityGroupName string = operations.outputs.networkSecurityGroupName
output operationsNetworkSecurityGroupResourceId string = operations.outputs.networkSecurityGroupResourceId
