$VmssResourceGroupName = "contoso-vmssagents-agentpool"
$GalleryResourceGroupName = "contoso-agentimages"
$SharedImageGalleryName = "sig.contoso.agent"
$ImageDefinitionName = "Windows2019"
$ImageDefinitionVersion = "1.1.48"  # Assuming max character account is 2 + 1 + 2 + 1 + 3 = 9
$Location = "East US 2"

# Naming restrictions: https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftcompute
# Windows max is 1-15
$MaxImageDefinitionNameLength = 51  # based on the total max for linux and other values used in the naming of the resource
$VmssName = "vmss{0}{1}" -f ($ImageDefinitionName.Substring(0, [System.Math]::Min($MaxImageDefinitionNameLength, $ImageDefinitionName.Length))), $ImageDefinitionVersion
$Subscription = "cbadc96b-2923-4459-bb2d-b237af7f84d6"
$ImageId = "/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Compute/galleries/{2}/images/{3}/versions/{4}" -f $Subscription, $GalleryResourceGroupName, $SharedImageGalleryName, $ImageDefinitionName, $ImageDefinitionVersion

# https://docs.microsoft.com/en-us/azure/virtual-machines/dv3-dsv3-series#dsv3-series

# Current issue with script
# "message": "OS disk of Ephemeral VM with size greater than 172 GB is not allowed for VM size Standard_DS3_v2 when the DiffDiskPlacement is CacheDisk."
$VmSku = "Standard_D8s_v3"

az group create --name $ResourceGroupName --location $Location

az vmss create `
--name $VmssName `
--resource-group $VmssResourceGroupName `
--image $ImageId `
--vm-sku $VmSku `
--storage-sku Standard_LRS `
--instance-count 2 `
--disable-overprovision `
--upgrade-policy-mode manual `
--single-placement-group false `
--platform-fault-domain-count 1 `
--load-balancer '""' `
--ephemeral-os-disk true `
--os-disk-caching readonly
