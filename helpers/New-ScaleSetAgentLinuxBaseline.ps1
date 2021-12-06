# https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/tutorial-use-custom-image-cli
# https://docs.microsoft.com/en-us/azure/virtual-machines/windows/build-image-with-packer
az account set -s 00000000-0000-0000-0000-000000000000
az group create --location westus --name vmssagents

az vmss create `
--name vmssbaselinelinuxagentspool `
--resource-group vmssagents `
--image UbuntuLTS `
--vm-sku Standard_D2_v3 `
--storage-sku StandardSSD_LRS `
--authentication-type SSH `
--instance-count 2 `
--disable-overprovision `
--upgrade-policy-mode manual `
--single-placement-group false `
--platform-fault-domain-count 1 `
--load-balancer '""'


