param name string
param location string
param tags object = {}
param retentionInDays int = 30
param skuName string = 'PerGB2018'
param workspaceCappingDailyQuotaGb int = -1

@description('Enable lock to prevent accidental deletion')
param enableDeleteLock bool = false

var lockName = '${logAnalyticsWorkspace.name}-lock'


resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    retentionInDays: retentionInDays
    sku:{
      name: skuName
    }
    workspaceCapping: {
      dailyQuotaGb: workspaceCappingDailyQuotaGb
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource lock 'Microsoft.Authorization/locks@2016-09-01' = if (enableDeleteLock) {
  scope: logAnalyticsWorkspace

  name: lockName
  properties: {
    level: 'CanNotDelete'
  }
}

output id string = logAnalyticsWorkspace.id
output name string = logAnalyticsWorkspace.name
output resourceGroupName string = resourceGroup().name
