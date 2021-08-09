

There are some initial infrastructure that needs to be setup prior to building and publishing images as well as supporting the infrastructure provisioning. 

1. Create an app registration and record it's information
2. 

## Resource Groups

### contoso-packer-builder
  
Used as a builder location for Packer to build images. It's a temporary place that you can give Packer to stand up VMs and run them then it tears them down after images have been built.

This resource group name is added to the pipeline as BuildResourceGroupName

### contoso-agentimages

This is the location where agents images are created. It's used to land managed images and also as a store for the Shared Image Gallery.

Storage account name:stcontosoagentimages
Shared Image Gallery:sig.contoso.agent

## contoso-vmssagents-agentpool

This is the location where all VM Scaled sets and VMS are created and used by the Agent pools in ADO.

# App Registration

Aware Baseline Agent Image App

Application (client) ID: 38612a51-3ab4-4a5e-9070-138c1a75582a

Object ID: 44071711-2f17-49af-a59e-b804f51c5676

# Managed (Enterprise) Application 

Name: Aware Baseline Agent Image App

Application ID: 38612a51-3ab4-4a5e-9070-138c1a75582a

Object ID: 7d976fe3-c37a-47b1-974f-420b387ffd68






