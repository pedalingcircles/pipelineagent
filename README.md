# Pipeline Agents

## Overview

This repository contains the source used to create Azure DevOps (ADO) [Self- hosted agents](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/agents?view=azure-devops&tabs=browser#install).

> Status: working towards an [MVP](https://en.wikipedia.org/wiki/Minimum_viable_product) release. Please don't consider this production ready.

There are two major components to the Self-hosted pipeline agents. *Image building* and *agent provisioning*.

### Image Building

Image building involves building and automating virtual machine (VM) images from scratch. The produced artifact is an [Azure managed disk](https://docs.microsoft.com/en-us/azure/virtual-machines/managed-disks-overview) that is generalized and published to an [Azure Compute Gallery](https://docs.microsoft.com/en-us/azure/virtual-machines/shared-image-galleries) (formally known as Shared Image Gallery). These images will include all dependencies needed on Azure DevOps (ADO) agents and include any predefined security and configuration settings. These images are leveraging the [HashiCorp Packer](https://www.packer.io/) tool for building the images.

### Operating Systems

The following operating systems are supported for VM image builds:

- Windows 2016 Server
- Windows 2019 Server
- Windows 2022 Server
- Ubuntu 1804
- Ubuntu 2004

### Agent Provisioning

Agent provisioning involves taking the built images and provisioning both self-hosted agents and scale set agents and then associating them to various [Agent pools](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/pools-queues?view=azure-devops&tabs=yaml%2Cbrowser) in the Azure DevOps (ADO) organization.

## Virtual Machine (VM) Image Definitions

| Definition | Included Software | Notes |
| --------------------|--------------------|--------------------|
| Ubuntu 20.04 | [ubuntu2004](vm-images/images/linux/Ubuntu2004-README.md) | **Do not use in production**. Product team developed image. Used as a reference to manage updates.
| Test Ubuntu 20.04 | [test-ubuntu2004](vm-images/images/linux/Ubuntu2004-README.md) | **Do not use in production**. Test image used to compare against ubuntu2004 to take updates.
| Ubuntu 18.04 | [ubuntu1804](vm-images/images/linux/Ubuntu1804-README.md) | **Do not use in production**. Product team developed image. Used as a reference to manage updated.
| Test Ubuntu 18.04 | [test-ubuntu1804](vm-images/images/linux/Ubuntu1804-README.md) | **Do not use in production**. Test image used to compare against ubuntu1804 to take updates.
| Windows Server 2022<sup>[beta]</sup> | [windows2022](.virtual-environments/images/win/Windows2022-Readme.md) | **Do not use in production**. Product team developed image. Used as a reference to manage updates.
| Test Windows Server 2022<sup>[beta]</sup> | [test-windows2022](vm-images/images/win/Windows2022-Readme.md) | **Do not use in production**. Test image used to compare against windows2022 to take updates.
| Windows Server 2019 | [windows2019](.virtual-environments/images/win/Windows2019-Readme.md) | **Do not use in production**. Product team developed image. Used as a reference to manage updates.
| Test Windows Server 2019 | [test-windowss2019](vm-images/images/win/Windows2019-Readme.md) | **Do not use in production**. Test image used to compare against windows2019 to take updates.
| Windows Server 2016 | [windows2016](.virtual-environments/images/win/Windows2016-Readme.md) | **Do not use in production**. Product team developed image. Used as a reference to manage updates.
| Test Windows Server 2016 | [test-windowss2016](vm-images/images/win/Windows2016-Readme.md) | **Do not use in production**. Test image used to compare against windows2016 to take updates.

## Getting Started

1. Setup RBAC to support Packer image generation
2. Test Packer image generation builds from user's machine
3. Setup build pipeline (CI) for the infrastruture
4. Setup image deploy (CD) pipeline for image building
5. Setup agent provisioning (CD) for ADO agent deployments
6. Setup VM Scale set provisioning

> Coming soon...more details :smiley:

## Updates from [actions/virtual-environments](https://github.com/actions/virtual-environments)

This repository uses the [actions/virtual-environments](https://github.com/actions/virtual-environments) repository to help with the Packer image builds. It's maintained by the Azure DevOps (ADO) product team to build the [hosted agents](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/hosted) provided by Azure DevOps (ADO). This is extremely useful since they automate the install and creation of many dependencies as well as configure the "baseline" images.

Updates from the [actions/virtual-environments](https://github.com/actions/virtual-environments) repository are needed in order to keep internal images up to date. General guidance is to create a temporary [git-subtree](https://github.com/git/git/blob/master/contrib/subtree/git-subtree.txt) and compare that against current images in the [vm-images](vm-images/) directory.

> see: [actions/virtual-environments Updates](docs/virtual-environments-updates.md) for guidance on how to keep this repository updated.

## Software and image guidelines

To learn more about tools and images support policy, see the [guidelines](docs/software-and-images-guidelines.md).