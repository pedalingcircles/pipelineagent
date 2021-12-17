param imageSubscriptionId string
param imageBuilderSubscriptionId string
param imageResourceGroupName string
param imageBuilderResourceGroupName string
param imageStorageAccountResourceId string
param imageBuilderResourceGroupResourceId string
param principalId string

module readerAndDataAccessRoleAssignment 'roleAssignment.bicep' = {
  name: 'packer-roleassignment-reader-and-data-access'
  scope: resourceGroup(imageSubscriptionId, imageResourceGroupName)
  params: {
    targetResourceId: imageStorageAccountResourceId
    roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/c12c1c16-33a1-487b-954d-41c89c60f349' // Reader and Data Access
    principalType: 'ServicePrincipal'
    principalId: principalId
  }
}

module storageBlobDataContributorRoleAssignment 'roleAssignment.bicep' = {
  name: 'packer-roleassignment-storageblob-datacontributor'
  scope: resourceGroup(imageSubscriptionId, imageResourceGroupName)
  params: {
    targetResourceId: imageStorageAccountResourceId
    roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/ba92f5b4-2d11-453d-a403-e96b0029c9fe' // Storage Blob Data Contributor
    principalType: 'ServicePrincipal'
    principalId: principalId
  }
}

module storageBlobDataReaderRoleAssignment 'roleAssignment.bicep' = {
  name: 'packer-roleassignment-storageblob-datareader'
  scope: resourceGroup(imageSubscriptionId, imageResourceGroupName)
  params: {
    targetResourceId: imageStorageAccountResourceId
    roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/2a2b9908-6ea1-4ae2-8e65-a410df84e7d1' // Storage Blob Data Reader
    principalType: 'ServicePrincipal'
    principalId: principalId
  }
}

module storageQueueDataContributorRoleAssignment 'roleAssignment.bicep' = {
  name: 'packer-roleassignment-storagequeue-datacontributor'
  scope: resourceGroup(imageSubscriptionId, imageResourceGroupName)
  params: {
    targetResourceId: imageStorageAccountResourceId
    roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/974c5e8b-45b9-4653-ba55-5f855dd0fb88' // Storage Queue Data Contributor
    principalType: 'ServicePrincipal'
    principalId: principalId
  }
}

module storageQueueDataReaderRoleAssignment 'roleAssignment.bicep' = {
  name: 'packer-roleassignment-storagequeue-datareader'
  scope: resourceGroup(imageSubscriptionId, imageResourceGroupName)
  params: {
    targetResourceId: imageStorageAccountResourceId
    roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/19e7f393-937e-4f77-808e-94535e297925' // Storage Queue Data Reader
    principalType: 'ServicePrincipal'
    principalId: principalId
  }
}

module imageBuilderResourceGroupRoleAssignment 'roleAssignment.bicep' = {
  name: 'packer-roleassignment-resourcegroup-contributor'
  scope: resourceGroup(imageBuilderSubscriptionId, imageBuilderResourceGroupName)
  params: {
    targetResourceId: imageBuilderResourceGroupResourceId
    roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c' // Contributor (resource group scoped)
    principalType: 'ServicePrincipal'
    principalId: principalId
  }
}
