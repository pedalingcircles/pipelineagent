<#
    .DESCRIPTION
        Legacy starter script work in progress.

        The idea is to havfe a clean up script to remove stage images during a pipeline run. 
#>


$ResourceGroupName = "contoso-agentimages"
$StorageAccountName = "stcontosoagentimages"
$ImagesContainerName = "images"
$SystemContainerName = "system"
$StaleBlobsDurationInDays = -.5



$ConnectionString = ""
# Query all blobs in storage account container
#Connect-AzAccount -Tenant 72f988bf-86f1-41af-91ab-2d7cd011db47 -Subscription cbadc96b-2923-4459-bb2d-b237af7f84d6

$Context = New-AzStorageContext -StorageAccountName $StorageAccountName -ConnectionString $ConnectionString

Get-AzStorageBlob -Container $ImagesContainerName -Context $Context | ForEach-Object {
    Write-Host ($_ | Format-Table | Out-String)
    $lastModified = $_.LastModified.UtcDateTime
    $duration = New-TimeSpan -End $lastModified
    $totalDays = $duration.TotalDays

    if ($totalDays -lt $StaleBlobsDurationInDays) {
        Remove-AzStorageBlob -Context $Context -Container $ImagesContainerName -Blob $_.Name
    }

    Write-Host "-------------------------------"
}


Get-AzStorageBlob -Container $ContainerName -Context $Context
#Get-AzStorageBlob -Container $ContainerName -Context $ctx | select Name


az storage blob list --container-name $ContainerName --account-name $StorageAccountName

Write-Host "Complete"
