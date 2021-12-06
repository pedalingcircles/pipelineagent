#!/bin/bash

organizationName='contoso'
location='eastus2'
subscription='00000000-0000-0000-0000-000000000000'
environmentType='sandbox'
templateFilePath='./pipelineagent/iac/adoagents-vms.bicep'
sshPubKeyFilePath=~/.ssh/foo.pub
adminPublicKey=$(cat "$sshPubKeyFilePath")

az deployment group create \
--resource-group 'rg-pipelineagent-sandbox-<uniqueid>-agent' \
--name agentVmDeployment \
--debug \
--no-prompt true \
--subscription $subscription \
--template-file $templateFilePath \
--parameters \
    environmentType=sandbox \
    organization=$organizationName \
    resourceGroupName='rg-pipelineagent-sandbox-<uniqueid>-agent' \
    adminPublicKey="$adminPublicKey" \
    existingSharedImageGalleryName='sig.contoso.images' \
    existingImageResourceGroupName='rg-contoso-images' \
    imageDefinitionName='ubuntu2004' \
    imageDefinitionVersion='1.0.0' \
    existingNetworkSecurityGroupName='nsg-agent' \
    existingVnetName='vnet-agent' \
    existingSubnetName='snet-agent' \
    existingStorageAccountName='stagentpa<uniqueid>' \
    scriptExtensionScriptUris='("https://stagentpa<uniqueid>.blob.core.windows.net/scriptextensions/hello.sh?sp=r&st=2021-10-21T17:21:25Z&se=2021-10-22T01:21:25Z&spr=https&sv=2020-08-04&sr=b&sig=i8Vad%2B2F1IPkDdr0le3MZc1fve5WNEXhLaXcvvdDwCs%3D", "https://stagentpasbxu63kxyluy6fd.blob.core.windows.net/scriptextensions/installer-agent-extension.sh?sp=foo")'
