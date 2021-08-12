
#Requires -Version 5.1
<#
.Synopsis
    Publishes an image to the Shared Image Gallery.

.DESCRIPTION
    Creates and image definition and an image version to a Shared Image Gallery. If the 
    image definition already exists, nothing happends, if not then it creates one. An 
    image version should always be associated with an image definition. 

.PARAMETER ResourceGroupName
    The resource group name the Shared Image Gallery and images are in.

.PARAMETER SharedImageGalleryName
    The Shared Image Gallery name.

.PARAMETER ImageDefinitionName
    The image definition name.

.PARAMETER ImagePublisher
    The publisher of the images.

.PARAMETER ImageOffer
    The offer of the images. These can typically by used by enterprise structure such
    as 'Finance' or related to teams.

.PARAMETER ImageSku
    The type of sku of the image. This is another way of categorizing the image. They
    can be 'Backend', 'Frontend', 'Build-Pool' or anything you like. 

.PARAMETER OsType
    The type of the OS that is included in the disk if creating a VM from user-image or a specialized VHD.
    Accepted values: Linux, Windows

.PARAMETER ImageVersion
    Gallery image version in semantic version pattern. The allowed characters are 
    digit and period. Digits must be within the range of a 32-bit 
    integer, e.g. <MajorVersion>.<MinorVersion>.<Patch>

.PARAMETER ImageName
    The name of the managed image as a source image.

.NOTES
    This script uses Azure CLI.

.LINK
    https://docs.microsoft.com/en-us/azure/virtual-machines/shared-image-galleries

#>

[CmdletBinding()]
param(
    [String] [Parameter (Mandatory=$true)] $ResourceGroupName,
    [String] [Parameter (Mandatory=$true)] $SharedImageGalleryName,
    [String] [Parameter (Mandatory=$true)] $ImageDefinitionName,
    [String] [Parameter (Mandatory=$true)] $ImagePublisher,
    [String] [Parameter (Mandatory=$true)] $ImageOffer,
    [String] [Parameter (Mandatory=$true)] $ImageSku,
    [String] [Parameter (Mandatory=$true)] $OsType,
    [String] [Parameter (Mandatory=$true)] $ImageVersion,
    [String] [Parameter (Mandatory=$true)] $ImageName
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

$imageId = az image list --resource-group $ResourceGroupName --query "[?contains(name, '$ImageName')].id | [0]" -o tsv
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
