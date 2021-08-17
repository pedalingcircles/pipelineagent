
#Requires -Version 5.1
<#
.Synopsis
    Publishes an image to an Azure Shared Image Gallery.

.DESCRIPTION
    Creates an image definition and an image version to a Shared Image Gallery. If the 
    image definition already exists, nothing happens, if not, then it creates one. An 
    image version should always be associated with an image definition. 

.PARAMETER ResourceGroupName
    The resource group name the Shared Image Gallery and images are in.

.PARAMETER SharedImageGalleryName
    The Shared Image Gallery name.

.PARAMETER ImageDefinitionName
    The image definition name. This values usually comes from the Packer image that was created.
    e.g. ubuntu1804, windows2019

.PARAMETER ImageDefinitionDescription
    The description of the gallery image definition.

.PARAMETER Location
    The Azure region to publish the image in.

.PARAMETER ImagePublisher
    The publisher of the image.

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

.PARAMETER EndOfLifeDate
    The end of life date of the image version.

.PARAMETER ImageVersionTags
    The tags to apply to the image version
    Recommended tags should include the following categories:
    - Buid Id
    - Build run
    - Environment type (e.g. dev, sbx, prod, nonprod)
    - Pool name
    - Team name
    - Portfolio name

    Tags are name value pairs seperated by a single white space
    example:key1=value1 key2=value2 key3=value3

.PARAMETER ImageDefinitionTags
    The tags to apply to the image definition.
    Recommended tags should include the following categories:
    - Buid Id
    - Build run
    - Environment type (e.g. dev, sbx, prod, nonprod)
    - Pool name
    - Team name 
    - Portfolio name

    Tags are name value pairs seperated by a single white space
    example:key1=value1 key2=value2 key3=value3

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
    [String] [Parameter (Mandatory=$true)] $ImageDefinitionDescription,
    [String] [Parameter (Mandatory=$true)] $Location,
    [String] [Parameter (Mandatory=$true)] $ImagePublisher,
    [String] [Parameter (Mandatory=$true)] $ImageOffer,
    [String] [Parameter (Mandatory=$true)] $ImageSku,
    [String] [Parameter (Mandatory=$true)] $OsType,
    [String] [Parameter (Mandatory=$true)] $ImageVersion,
    [String] [Parameter (Mandatory=$true)] $ImageName,
    [String] [Parameter (Mandatory=$true)] $EndOfLifeDate,
    [array][Parameter(Mandatory=$true)]$ImageVersionTags,
    [array][Parameter(Mandatory=$true)]$ImageDefinitionTags,
    [switch]$Clean
)

try {
    $endOfLiveDateTime = [DateTime] $EndOfLifeDate
    $endOfLiveDateIso = (Get-Date -AsUTC -Date (   (Get-Date $endOfLiveDateTime).AddDays(-7)) -Format s) + "Z"
    Write-Host "endOfLiveDateIso=$endOfLiveDateIso"
    $imageId = $(az image list --resource-group $ResourceGroupName --query "[?contains(name, '$ImageName')].id | [0]" -o tsv)
    Write-Host "imageId=$imageId"

    Write-Host "Creating new image definition: '$ImageDefinitionName'"
    $imageDefinitionResult = $(az sig image-definition create `
        --resource-group $ResourceGroupName `
        --gallery-name $SharedImageGalleryName `
        --gallery-image-definition $ImageDefinitionName `
        --publisher $ImagePublisher `
        --hyper-v-generation V2 `
        --offer $ImageOffer `
        --sku $ImageSku `
        --os-type $OsType `
        --os-state Generalized `
        --description $ImageDefinitionDescription `
        --tags ${ImageDefinitionTags}) `
        | ConvertFrom-Json
    if ($imageDefinitionResult.provisioningState -ne "Succeeded") {
        throw "Error while creating the image definition. Provisioning did not succeed:" + ($imageDefinitionResult | Format-List | Out-String)
    }
    Write-Host ($imageDefinitionResult | Format-List | Out-String)

    Write-Host "Creating new Azure managed image with image name: '$imageName'"
    $imageVersionResult = $(az sig image-version create `
        --resource-group $ResourceGroupName `
        --gallery-name $SharedImageGalleryName `
        --gallery-image-definition $ImageDefinitionName `
        --gallery-image-version $ImageVersion `
        --location $Location `
        --managed-image $imageId `
        --end-of-life-date $endOfLiveDateIso `
        --tags ${ImageVersionTags}) `
        | ConvertFrom-Json
    if ($imageVersionResult.provisioningState -ne "Succeeded") {
        throw "Error while creating the image version. Provisioning did not succeed:" + ($imageDefinitionResult | Format-List | Out-String)
    }
    Write-Host ($imageVersionResult | Format-List | Out-String)

} catch {
    Write-Host "##vso[task.logissue type=error]There was an error creating the image definition and or the image version"
    Write-Host $_
} finally {
    if ($imageVersionResult.provisioningState -eq "Succeeded" -and $Clean) {
        Write-Host "Deleting manged image..."
        $deleteResult = $(az image delete --ids $imageId)
        Write-Host $deleteResult
    } else {
        Write-Host "##vso[task.logissue type=warning]Could not clean up the managed image. This could be due errors in access or the 'Clean' switch wasn't set."
    }
}
