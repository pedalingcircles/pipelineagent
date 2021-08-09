$storageAccountName = "stcontosoagentimages"
$containerName = "system"
$buildNumber = "ci-packerimage-ubuntu2004-20210303-2"
$buildNumber = "ci-packerimage-Ubuntu2004-20210303-2"
$prefix = "Microsoft.Compute/Images/{0}" -f $buildNumber
$vhdName = az storage blob list --container-name $containerName --account-name $storageAccountName --prefix $prefix --query "[?contains(name, 'vhd')].name | [0]" -o tsv
$vhdDiskUri = "https://${0}.blob.core.windows.net/system/{1}" -f $storageAccountName, $vhdName
Write-Host "vhdDiskUri=$vhdDiskUri"


