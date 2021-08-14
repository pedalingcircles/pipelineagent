# Pipeline Agents

## Overview

Pipeline Agents is intended to support Azure DevOps agent automation. This repository includes all the documentation and tools to get started. This repo specifically targets Agent Pools that support VM scale sets. As this automation matures, more agent types will be included.

## Build Statuses

*TBD*

## Getting Started

There are two major parts to getting started.

1. Setting up automation for building VM images
2. Provisioning agent infrastructure and setting up Azure Devops Agent pools

Docuemntations, tutorials, and guides will be found here.

## Bootstrapping

Some tasks requires some bootstrapping actions to be setup for items that are run the very first time. This is especially important when setting up agents. Take a look at the [bootstrapping docs](docs/bootstrapping.md)

# Subtree

There are currently two Git subtrees in this repo.

- [.AzureDevOps-agents](./.virtual-environments)
- [.virtual-environments](./.AzureDevOps-agents)
