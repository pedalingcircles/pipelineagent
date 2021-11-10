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

@description('The Azure DevOps (ADO) agent pool name.')
param agentPool string

@secure()
@description('The personal access token (PAT) used to setup the agent in the agent pool in ADO.')
param pat string

@description('The URL of the ADO organization.')
param orgUrl string

@description('Represents a to differiantate on a side by side deployments if needed.')
@maxLength(15)
@allowed([
  'b'   // Represents blue
  'g'   // Represents green
])
param blueGreen string = 'b'

@description('Used to identify the type of workload.')
@maxLength(15)
param workload string = 'pipelineagent'

@description('Abbreviated values of the workload.')
@maxLength(4)
param workloadShort string = 'pa'

@description('The organization that\'s responsible for the workload.')
param organization string

@description('Date string used to uniquely identify a deployment name.')
param nowUtc string = utcNow()

@description('The location of the virtual machine resources.')
param location string = resourceGroup().location

@description('The agent resource group name.')
param resourceGroupName string

@description('Tags used to label the network interface card(s).')
param nicTags object = {
  'environmentType': environmentType
  'org': organization
  'workload': workload
  'component': 'vmagent'
}

@description('Tags used to label the VMs.')
param vmTags object = {
  'environmentType': environmentType
  'org': organization
  'workload': workload
  'component': 'vmagent'
  'os': 'linux'
  'imagedefinitionname': imageDefinitionName
  'imagedefinitionversion': imageDefinitionVersion
}

@description('The IP config name for the VMs.')
param ipConfigName string = 'vm-agent-ip-config'

@description('Specifies the size of the virtual machine.')
@allowed([
  'Standard_D2_v3' 
  'Standard_D8s_v3'
])
param vmSize string = 'Standard_D8s_v3'

@description('Specifies information about the operating system disk used by the VMs.')
param osDiskType string = 'StandardSSD_LRS'

@description('Specifies the name of the administrator account.')
param adminUsername string = 'azureuser'

@description('The SSH RSA public key file as a string. Use "ssh-keygen -t rsa -b 2048" to generate your SSH key pairs.')
@minLength(14)
param adminPublicKey  string

@description('The existing Shared Image Gallery name.')
param existingSharedImageGalleryName string

@description('The existing image resource group name.')
param existingImageResourceGroupName string

@description('The existing network security group name in the virtual network that hosts the VMs.')
param existingNetworkSecurityGroupName string

@description('The existing virtual network name that hosts the VMs.')
param existingVnetName string

@description('The existing subnet name in the virtual network that hosts the VMs.')
param existingSubnetName string

@description('The image definition to use. This value is in the Shared Image Gallery')
param imageDefinitionName string

@description('The image definition version ot use.')
param imageDefinitionVersion string

@description('Array of URLs for the script extensions used by the VMs.')
param scriptExtensionScriptUris array

@description('The existing storage account name used by the VMs.')
param existingStorageAccountName string

var resourceNamePlaceholderShort = '${workloadShort}[delimiterplaceholder]${environmentTypeShort}[delimiterplaceholder]${blueGreen}'
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
var linuxVmName = take('vm-${replace(resourceNamePlaceholderShort, '[delimiterplaceholder]', '-')}', 64)
var nicName =  take('nic-${replace(resourceNamePlaceholderShort, '[delimiterplaceholder]', '-')}', 80)

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
    agentPool: agentPool
    pat: pat
    orgUrl: orgUrl
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
    scriptExtensionScriptUris: scriptExtensionScriptUris
    existingStorageAccountName: existingStorageAccountName
  }
}
