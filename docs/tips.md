# Tips

## Export Template

First create resources using the Azure Portal then export the template.
Copy that json file and then use that to decompile to to Bicep

```azurecli
az group export --name "your_resource_group_name" --subscription 00000000-0000-0000-0000-000000000000 > main.json
az bicep decompile --file main.json
```

see: [Decompiling ARM template JSON to Bicep](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/decompile?tabs=azure-cli)

## Packer Agent Access

During Packer VM Image generation you have two options:

1. Set the virtual network and subnet in the Packer template for __self-hosted__ agents
2. Removed the virtual network and subnet in the Packer template and set the `allowed_inbound_ip_addresses` value to the __hosted agent__ IP.

> You might see an SSH timout if using hosted agents due to no line of site

## Git Subtree

Use sub trees instead of Git Modules to pull in dependent repos under this repo. 

```azurecli
git subtree pull --prefix .virtual-environments https://github.com/actions/virtual-environments.git main --squash
```

## Bicep what-if

Perform a what if on a Bicep file before deployment to identify any potential issues. The return value
will also show results of what will be added, modified, or deleted.

Parameters inline

```azurecli
az deployment group what-if --resource-group mijohns-vnet-sbx --subscription 00000000-0000-0000-0000-000000000000 --template-file ./contoso-net-template.bicep --parameters bastionHostName='bastion-agent' nsgVmAgent='nsg-azurevmagent' bastionNsgName='nsg-bastion' bastionPipName='bastion-pip' vnetName='vnet-agents'
```

Parameter file

```azurecli
az deployment group what-if --resource-group mijohns-vnet-sbx --subscription cbadc96b-2923-4459-bb2d-b237af7f84d6 --template-file iac/contoso-net-template.bicep --parameters iac/contoso-net-template.parameters.sbx.json
```

## Git subtree

This repo is dependent upon other repos. Mostly the Github Actions and Azure DevOps pipeline product team's repo actions/virtual-environments. 
We use a Git subtree to pull in and reference this repo 

`git subtree add --prefix .virtual-environments https://github.com/actions/virtual-environments.git main --squash`

