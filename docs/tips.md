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
az deployment group what-if --resource-group mijohns-vnet-sbx --subscription 00000000-0000-0000-0000-000000000000 --template-file iac/contoso-net-template.bicep --parameters iac/contoso-net-template.parameters.sbx.json
```

## Subnet calculator

This is used to divide up Vnets into Subnets
[Visual Subnet Calculator](https://www.davidc.net/sites/default/subnets/subnets.html)


## Agent Software

It's a challenge to both automatically find the correct software endpoint, but also download it as well as install it.

The standard URL to download agent software is the following. Note that this could change at anytime so a better method is suggested:
https://vstsagentpackage.azureedge.net/agent/<agentversion>/vsts-agent-linux-x64-<agentversion>.tar.gz

An [Issue](https://github.com/microsoft/azure-pipelines-agent/issues/1333#issuecomment-352471130) was raised in GitHub that referenced an API, but I can't find this API documented anywhere:
https://account.visualstudio.com/_apis/distributedtask/packages/agent?%24top=1

An [Issue](https://github.com/microsoft/azure-pipelines-agent/issues/1423#issuecomment-367384800) was raised in GitHub that referenced getting the related asset information to find out the official endpoints to download the agent software.

``` bash
curl -s https://api.github.com/repos/Microsoft/vsts-agent/releases/latest | jq -r .assets[].browser_download_url





```



