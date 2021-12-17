# Only clean original blobs in the storage container  if we know the managed image was created.
if ($imageCreateResult.provisioningState -eq "Succeeded" -and $Clean) {
    # Cleaning up blobs directly related to the image creation
    az storage blob delete-batch --source $ContainerName --auth-mode login --account-name $StorageAccountName --pattern '$PrefixFilter*'

    # Cleaning up blobs associated with working vm images. These are throw away and only needed while Packer is building an image
    $modifiedDate = (Get-Date -AsUTC -Date ((Get-Date).AddDays(-$CleanBlobsDaysOld)) -Format s) + "Z"
    Write-Host "Cleaning up all blobs in the 'images' container since '$modifiedDate'" only if they exist

    [array]$dateResults = $(az storage blob list --container-name images --auth-mode login --account-name $StorageAccountName --query "[?properties.lastModified<``$modifiedDate``].properties.lastModified"  -o tsv)
    Write-Host "Looking up vhd blobs to delete based on last modified date '$modifiedDate': $dateResults"
    if ($dateResults.Length -gt 0) {
        Write-Host "Attempting to delete vhd blobs..."
        az storage blob delete-batch --source images --auth-mode login --pattern *.vhd --account-name $StorageAccountName --if-unmodified-since $modifiedDate
    } else {
        Write-Host "There are no blobs to delete due to not modified since '$modifiedDate'"
    }
    
} else {
    Write-Host "##vso[task.logissue type=warning]Could not clean up the working vhd blobs in the 'images' container. This could be due errors in access or the 'Clean' switch wasn't set."
}