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
param environmentType string = 'sandbox'

@description('Used to identify the type of workload.')
@maxLength(15)
param workload string = 'pipelineagent'
param workloadShort string = 'pa'

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

var resourceNamePlaceholder = '${workload}[delimiterplaceholder]${environmentType}[delimiterplaceholder]${uniqueId}'
var resourceNamePlaceholderShort = '${workloadShort}[delimiterplaceholder]${environmentTypeShort}[delimiterplaceholder]${uniqueId}'

output uniqueId string = uniqueId
output environmentTypeShort string = environmentTypeShort
output environmentType string = environmentType
output resourceName string = resourceNamePlaceholder
output resourceNameShort string = resourceNamePlaceholderShort



