

## White listing Agent IPs

This setting was added in the last year to the Packer config and it allows you to white list a hosted agent to only allow
traffic from the agent to the working vm instance. It's used by setting the `allowed_inbound_ip_addresses` Packer 
variable to $AgentIP. The $AgentIP in the build-image.ps1 script dynamically grabs the current IP of the 
agent during a pipeline run and sets this IP. Note that this won't work with self-hosted agents since they 
will likely NOT have any internet access so settings the static IP up front for every run is probably unlikely. 

This is useful in scenarios when you need to bootstrap. For example, if you have zero self-host agents and need
a hosted agent to first built you one, then this is a good scenario. 

> You can't use/set the `virtual_network_name`, `virtual_network_resource_group_name`, and the `virtual_network_name` when using this.

## Static Virtual Network

You can set the virtual network, the subnet, and the resource group up front. What this will do is when Packer generates a working VM 
to create an image, it won't create it's own virtual network, it will use the existing one specified. You can't use white listing above
in this scenario. They are mutually exclusive. 

> There is currently an issue with connecting to the microsoft package. This is unresolved and is likely due to blocking traffic. 

sample log snippet


<span style="color:red">
==> azure-arm: --2021-08-10 22:58:56--  https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb</br>
==> azure-arm: Resolving packages.microsoft.com (packages.microsoft.com)... 13.90.21.104 </br>
==> azure-arm: Connecting to packages.microsoft.com (packages.microsoft.com)|13.90.21.104|:443... failed: Connection timed out.
</span>
