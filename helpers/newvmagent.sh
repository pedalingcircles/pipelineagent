#!/bin/bash

organizationName='contoso'
location='eastus2'
subscription='cbadc96b-2923-4459-bb2d-b237af7f84d6'
environmentType='sandbox'
templateFilePath='/mnt/c/Users/mijohns/Source/repos/byvrate/pipelineagent/iac/templates/agents-virtualmachine.bicep'
sshPubKeyFilePath=~/.ssh/vmagent-priv-key.pub
adminPublicKey=$(cat "$sshPubKeyFilePath")

az deployment group create \
--resource-group 'rg-pipelineagent-sandbox-u63kxyluy6fdo-agent' \
--name agentVmDeployment \
--debug \
--no-prompt true \
--subscription $subscription \
--template-file $templateFilePath \
--parameters \
    environmentType=sandbox \
    organization=$organizationName \
    resourceGroupName='rg-pipelineagent-sandbox-u63kxyluy6fdo-agent' \
    adminPublicKey="$adminPublicKey" \
    existingSharedImageGalleryName='sig.contoso.images' \
    existingImageResourceGroupName='rg-contoso-images' \
    imageDefinitionName='ubuntu2004' \
    imageDefinitionVersion='1.0.76' \
    existingNetworkSecurityGroupName='nsg-agent' \
    existingVnetName='vnet-agent' \
    existingSubnetName='snet-agent' \
    existingStorageAccountName='stagentpasbxu63kxyluy6fd' \
    scriptExtensionScriptUris='("https://stagentpasbxu63kxyluy6fd.blob.core.windows.net/scriptextensions/hello.sh?sp=r&st=2021-10-21T17:21:25Z&se=2021-10-22T01:21:25Z&spr=https&sv=2020-08-04&sr=b&sig=i8Vad%2B2F1IPkDdr0le3MZc1fve5WNEXhLaXcvvdDwCs%3D", "https://stagentpasbxu63kxyluy6fd.blob.core.windows.net/scriptextensions/installer-agent-extension.sh?sp=r&st=2021-10-21T17:22:09Z&se=2021-10-22T01:22:09Z&spr=https&sv=2020-08-04&sr=b&sig=w1uvp9Et3K9s5Ofm4DBoT4WHRqtELYY7FF6bwi3fY%2F8%3D")'
