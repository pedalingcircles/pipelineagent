# https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/tutorial-use-custom-image-cli
# https://docs.microsoft.com/en-us/azure/virtual-machines/windows/build-image-with-packer
az account set -s 00000000-0000-0000-0000-000000000000
az group create --location westus --name vmssagents

az vmss create `
--name vmssbaselinewindowsagentspool `
--resource-group vmssagents `
--image Win2019Datacenter `
--vm-sku Standard_D8s_v3 `
--storage-sku StandardSSD_LRS `
--instance-count 2 `
--disable-overprovision `
--upgrade-policy-mode manual `
--single-placement-group false `
--platform-fault-domain-count 1 `
--load-balancer '""'


