
# https://stagentimage001.blob.core.windows.net/system/Microsoft.Compute/Images/images/packer-osDisk.1f058594-eabc-4cc1-8066-bfca700264ef.vhd
az storage blob show --container-name images --account-name stagentimage001 --name pkros10hlu5rula.vhd

$storageAccountName = "stagentimage001"
$containerName = "system"
$containerPath = "Microsoft.Compute/Images/images"
$vhdBlobName = "packer-osDisk.1f058594-eabc-4cc1-8066-bfca700264ef"
$blobUrl = "https://{0}.blob.core.windows.net/{1}/{2}/{3}.vhd" -f  $storageAccountName, $containerName, $containerPath, $vhdBlobName

az disk create --resource-group msft-aware-imagegen-agent-ci --name $vhdBlobName --source $blobUrl
az image create --resource-group msft-aware-imagegen-agent-ci --name $vhdBlobName --os-type Windows --source /subscriptions/cbadc96b-2923-4459-bb2d-b237af7f84d6/resourceGroups/msft-aware-imagegen-agent-ci/providers/Microsoft.Compute/disks/packer-osDisk.1f058594-eabc-4cc1-8066-bfca700264ef
Write-Host "stop"
