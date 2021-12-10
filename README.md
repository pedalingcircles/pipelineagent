# Pipeline Agents

## Overview

This repository contains the source used to create Azure DevOps (ADO) [Self- hosted agents](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/agents?view=azure-devops&tabs=browser#install).

> This repo is working towards an [MVP](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/agents?view=azure-devops&tabs=browser#install) status. Please don't consider this production ready.

There are two major components to the Self-hosted pipeline agents. Image building and agent provisioning.

### Image Building

Image building involves building and automating Virtual Machine (VM) images from scratch. The produced artifact is an [Azure managed disk](https://docs.microsoft.com/en-us/azure/virtual-machines/managed-disks-overview) that is generalized and published to an [Azure Compute Gallery](https://docs.microsoft.com/en-us/azure/virtual-machines/shared-image-galleries) (formally known as Shared Image Gallery). These images will include all dependencies needed on agents and include any predefined security and configuration settings. These images are leveraging [HashiCorp Packer](https://www.packer.io/) as a tool for building the images.

### Agent Provisioning

Agent provisioning involved taking the pre-defined and approved images and provisioning and deploying both VM Agents and Scaled set agents and attaching them to Agent Pools to be used by Azure DevOps pipelines.

## Build Statuses

All builds are done internally.

## Image Definitions

| Environment | YAML Label | Included Software |
| --------------------|---------------------|--------------------|
| Ubuntu 20.04 | `ubuntu-20.04` | [ubuntu-20.04](.virtual-environments/images/linux/Ubuntu2004-README.md)
| Ubuntu 18.04 | `ubuntu-18.04` | [ubuntu-18.04](.virtual-environments/images/linux/Ubuntu1804-README.md)
| Windows Server 2022<sup>[beta]</sup> | `windows-2022` | [windows-2022](.virtual-environments/images/win/Windows2022-Readme.md)
| Windows Server 2019 | `windows-2019` | [windows-2019](.virtual-environments/images/win/Windows2019-Readme.md)
| Windows Server 2016 | `windows-2016` | [windows-2016](.virtual-environments/images/win/Windows2016-Readme.md)

## Getting Started

1. Create service principal for the use of Packer
2. Setup build pipeline (CI) for the infrastruture
3. Setup image deploy pipeline for image building
4. Setup agent provisioning for stand-along VM agents
5. Setup VM Scale set provisioning

> TDB: More details will coming on getting started.

## Bootstrapping

Some tasks require some bootstrapping actions to be setup for items that are run the very first time. This is important when setting up agents. Take a look at the [bootstrapping docs](docs/bootstrapping.md). In short, you need and agent to deploy an agent.

## Subtree

This repo used the [actions/virtual-environments](https://github.com/actions/virtual-environments) repo that's maintained by the Azure DevOps and Github product teams. A subtree is pulled in (see [tips](.docs/../docs/tips.md#git-subtree)) to compare and and update changes. The taret directory is [vm-images](vm-images). This directory aligns with the repo [images](https://github.com/actions/virtual-environments/tree/main/images) directory.