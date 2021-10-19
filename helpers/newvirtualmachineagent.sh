#!/bin/bash

organizationName='contoso'
location='eastus2'
subscription='cbadc96b-2923-4459-bb2d-b237af7f84d6'
environmentType='sandbox'
templateFilePath='/mnt/c/Users/mijohns/Source/repos/byvrate/pipelineagent/iac/templates/agents-virtualmachine.bicep'
sshPubKeyFilePath=~/.ssh/vmagent-priv-key.pub
adminPublicKey=$(cat "$sshPubKeyFilePath")

echo $adminPublicKey

az deployment group create \
--resource-group 'rg-pipelineagent-sandbox-u63kxyluy6fdo-agent' \
--name agentVmDeployment \
--no-prompt true \
--subscription $subscription \
--template-file $templateFilePath \
--parameters \
    environmentType=sandbox \
    organization=$organizationName \
    resourceGroupName='rg-pipelineagent-sandbox-u63kxyluy6fdo-agent' \
    adminPublicKey='$adminPublicKey' \
    existingSharedImageGalleryName='sig.contoso.images' \
    existingImageResourceGroupName='rg-contoso-images' \
    imageDefinitionName='ubuntu2004' \
    existingNetworkSecurityGroupName='nsg-agent' \
    existingSubnetName='snet-agent'