$VmssResourceGroupName = "rg-foo-agents-sbx-eastus2-001"
$GalleryResourceGroupName = "rg-contoso-images"
$SharedImageGalleryName = "sig.contoso.images"
$ImageDefinitionName = "Ubuntu2004"
$ImageDefinitionVersion = "1.0.74"  # Assuming max character account is 2 + 1 + 2 + 1 + 3 = 9
$Location = "eastus2"
$Subnet = "snet-vmagent"
$Vnet = "vnet-agents"

# Naming restrictions: https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftcompute
# Linux max is 1-64
$MaxImageDefinitionNameLength = 51  # based on the total max for linux and other values used in the naming of the resource
$VmssName = "vmss{0}{1}" -f ($ImageDefinitionName.Substring(0, [System.Math]::Min($MaxImageDefinitionNameLength, $ImageDefinitionName.Length))), $ImageDefinitionVersion
$Subscription = "00000000-0000-0000-0000-000000000000"
$ImageId = "/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Compute/galleries/{2}/images/{3}/versions/{4}" -f $Subscription, $GalleryResourceGroupName, $SharedImageGalleryName, $ImageDefinitionName, $ImageDefinitionVersion
$VmSku = "Standard_DS3_v2"

#az group create --name $ResourceGroupName --location $Location

az vmss create `
--name $VmssName `
--resource-group $VmssResourceGroupName `
--image $ImageId `
--vm-sku $VmSku `
--location $Location `
--storage-sku Standard_LRS `
--authentication-type SSH `
--instance-count 2 `
--disable-overprovision `
--upgrade-policy-mode manual `
--single-placement-group false `
--subnet $Subnet `
--vnet-name $Vnet `
--platform-fault-domain-count 1 `
--load-balancer '""' `
--ephemeral-os-disk true `
--os-disk-caching readonly