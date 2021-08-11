


[CmdletBinding()]
param(
    [String] [Parameter (Mandatory=$true)] $ResourceGroupName,
    [String] [Parameter (Mandatory=$true)] $SharedImageGalleryName,
    [String] [Parameter (Mandatory=$true)] $ImageDefinitionName,
    [String] [Parameter (Mandatory=$true)] $ImagePublisher,
    [String] [Parameter (Mandatory=$true)] $ImageOffer,
    [String] [Parameter (Mandatory=$true)] $ImageSku,
    [String] [Parameter (Mandatory=$true)] $OsType,
    [String] [Parameter (Mandatory=$true)] $ImageVersion
)

az sig image-definition create `
    --resource-group $ResourceGroupName `
    --gallery-name $SharedImageGalleryName `
    --gallery-image-definition $ImageDefinitionName `
    --publisher $ImagePublisher `
    --offer $ImageOffer `
    --sku $ImageSku `
    --os-type $OsType `
    --os-state Generalized

$imageId = az image list --resource-group $(ResourceGroupName) --query "[?contains(name, '$imageName')].id | [0]" -o tsv
Write-Host "imageId=$imageId"

az sig image-version create `
    --resource-group $ResourceGroupName `
    --gallery-name $SharedImageGalleryName `
    --gallery-image-definition $ImageDefinitionName `
    --gallery-image-version $ImageVersion `
    --managed-image $imageId

# If gallery image version is created, delete the managed image, it's no longer needed
az image delete --ids $imageId
Write-Host "Managed image deleted $imageId"
