// scope
targetScope = 'resourceGroup'

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
var uniqueId = uniqueString(deployment().name)

param location string = resourceGroup().location
param resourceGroupName string

param nicTags object = {
  'environmentType': environmentType
  'org': organization
  'workload': workload
  'component': 'vmagent'
}

param vmTags object = {
  'environmentType': environmentType
  'org': organization
  'workload': workload
  'component': 'vmagent'
  'os': 'linux'
  'imagedefinitionname': imageDefinitionName
  'imagedefinitionversion': imageDefinitionVersion
}

param ipConfigName string = 'vm-agent-ip-config'

@description('Used to identify environment types for naming resources.')
@allowed([
  'Standard_D2_v3' 
  'Standard_D8s_v3'
])
param vmSize string = 'Standard_D8s_v3'
param osDiskType string = 'StandardSSD_LRS'
param adminUsername string = 'azureuser'

@description('The SSH RSA public key file as a string. Use "ssh-keygen -t rsa -b 2048" to generate your SSH key pairs.')
@minLength(14)
param adminPublicKey  string

//var resourceNamePlaceholder = '${workload}[delimiterplaceholder]${environmentType}[delimiterplaceholder]${uniqueId}'
var resourceNamePlaceholderShort = '${workloadShort}[delimiterplaceholder]${environmentTypeShort}[delimiterplaceholder]${uniqueId}'

param existingSharedImageGalleryName string
param existingImageResourceGroupName string
param existingNetworkSecurityGroupName string
param existingVnetName string
param existingSubnetName string
param imageDefinitionName string
param imageDefinitionVersion string

//var windowsVmName = take('vm${replace(resourceNamePlaceholderShort, '[delimiterplaceholder]', '')}', 15)

// os type (already in the definition name)
// image
// version
// bg
var linuxVmName = take('vm-${replace(resourceNamePlaceholderShort, '[delimiterplaceholder]', '-')}', 64)
var nicName =  take('nic-${replace(resourceNamePlaceholderShort, '[delimiterplaceholder]', '')}', 80)


module virtualMachine './modules/linuxVirtualMachineAgent.bicep' = {
  name: 'deploy-agent-virtualmachine-${nowUtc}'
  scope: resourceGroup(resourceGroupName)
  params: {
    vmName: linuxVmName
    nicName: nicName
    location: location
    vmTags: vmTags
    nicTags: nicTags
    ipConfigurationName: ipConfigName
    vmSize: vmSize
    osDiskType: osDiskType
    adminUsername: adminUsername
    adminPublicKey: adminPublicKey
    existingSharedImageGalleryName: existingSharedImageGalleryName
    existingImageResourceGroupName: existingImageResourceGroupName
    imageDefinitionName: imageDefinitionName
    imageDefinitionVersion: imageDefinitionVersion
    existingNetworkSecurityGroupName: existingNetworkSecurityGroupName
    existingSubnetName: existingSubnetName
    existingVnetName: existingVnetName
  }
}
