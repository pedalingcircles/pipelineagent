<#
.SYNOPSIS
    Publishes an image to an an Azure Shared Image Gallery (now called Compute Gallery).

.DESCRIPTION
    Creates an image definition and publishes an image version to Azure Shared Image Gallery
    (now called Compute Gallery). If the image definition
    already exists, nothing happens, if not, then it creates one. An 
    image version should always be associated with an image definition and
    use a Semantic Version.

.PARAMETER ResourceGroupName
    The resource group name of the Shared Image Gallery and images are in.

.PARAMETER SharedImageGalleryName
    The Shared Image Gallery name.

.PARAMETER ImageDefinitionName
    The image definition name. This values usually 
    comes from the Packer image that was created. 
    e.g. ubuntu1804, windows2019

.PARAMETER ImageDefinitionDescription
    The description of the gallery image definition.

.PARAMETER Location
    The Azure region to publish the image in.

.PARAMETER ImagePublisher
    The publisher of the image.

.PARAMETER ImageOffer
    The offer of the image. These can typically by used 
    by enterprise an org such as 'Finance' or related to teams.

.PARAMETER ImageSku
    The type of SKU of the image. This is another way of categorizing the image.
    They can be 'Backend', 'Frontend', 'Build-Pool' or anything you like. 

.PARAMETER OsType
    The type of the OS that is included in the disk if 
    creating a VM from user-image or a specialized VHD.
    Accepted values: Linux, Windows

.PARAMETER ImageVersion
    Gallery image version in Semantic Version pattern. The allowed characters are 
    digit and period. Digits must be within the range of a 32-bit integer.
    e.g. <MajorVersion>.<MinorVersion>.<Patch> 

    The 'pre-release' and 'metadata' parts of 
    Semantic Version are not supported.

.PARAMETER ImageName
    The name of the managed image to publish.

.PARAMETER EndOfLifeDate
    The end of life date of the published image. It's recommended
    to use an ISO 8601 date time string. However, Powershell will 
    parse whatever string that is passed in. 

    e.g. "2023-12-16"
    e.g. "2023-12-16T05:01:54Z"
    e.g. "2023-12-16T05:01:54+00:00"

.PARAMETER ImageVersionTags
    The tags to apply to the image version.

.PARAMETER ImageDefinitionTags
    The tags to apply to the image definition.

.PARAMETER Clean
    A switch when set removed the Virtual Machine (VM) managed
    image after publication to the gallery.

.EXAMPLE

    PS> .\Publish-ImageToSharedGallery.ps1 -ResourceGroupName rg-contoso -SharedImageGalleryName cg.contoso.gallery `
    -ImageDefinitionName ubuntu1804 -ImageDefinitionDescription 'image description' -ImagePublisher Contoso `
    -ImageOffer Finance -ImageSku Backend -OsType Linux -ImageVersion 1.2.0 -ImageName adoagent-ubuntu1804 `
    -ReleaseNoteUri https://contoso.com/releasenotes.md -EndOfLifeDate 2023-12-16T05:01:54Z `
    -ImageVersionTags @(\"env=dev\",\"workload=ado agent\") -ImageDefinitionTags @(\"env=dev\",\"workload=ado agent\")

.EXAMPLE

    PS> .\Publish-ImageToSharedGallery.ps1 -ResourceGroupName rg-contoso -SharedImageGalleryName cg.contoso.gallery `
    -ImageDefinitionName windows2019 -ImageDefinitionDescription 'image description' -ImagePublisher Contoso `
    -ImageOffer IT -ImageSku Frontend -OsType Windows -ImageVersion 2.5.6 -ImageName adoagent-windows2019 `
    -ReleaseNoteUri https://contoso.com/releasenotes.md -EndOfLifeDate 2023-11-19T03:01:54Z `
    -ImageVersionTags @(\"env=dev\",\"workload=ado agent\") -ImageDefinitionTags @(\"env=dev\",\"workload=ado agent\") -Clean

.NOTES
    This script uses Azure CLI and supports being run interactively 
    as well as from an Azure DevOps pipeline.

    This script references Azure Shared Image Gallery which is now called
    Azure Compute Gallery. We are keeping all the names and resource calls 
    referencing Shared Image Gallery insted of Computer Gallery (for now) due to the 
    operations and command and APIs still leveraging the legacy names. 

    Recommended tags should include the following categories:
    - Buid Id
    - Git ref
    - Git repo
    - Environment type (e.g. dev, sbx, prod, nonprod)
    - Environment use (e.g. agent)
    - Agent pool name
    - Team name
    - Workload

.LINK
    https://docs.microsoft.com/en-us/azure/virtual-machines/shared-image-galleries

.LINK
    https://semver.org
#>

#Requires -Version 5.1

[CmdletBinding()]
param(
    [Parameter (Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroupName,

    [Parameter (Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$SharedImageGalleryName,

    [Parameter (Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$ImageDefinitionName,

    [Parameter (Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$ImageDefinitionDescription,

    [Parameter (Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$Location,

    [Parameter (Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$ImagePublisher,

    [Parameter (Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$ImageOffer,

    [Parameter (Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$ImageSku,

    [Parameter (Mandatory=$true)]
    [ValidateSet("Linux", "Windows")]
    [ValidateNotNullOrEmpty()]
    [string]$OsType,

    [Parameter (Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$ImageVersion,

    [Parameter (Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$ImageName,

    [Parameter (Mandatory=$false)]
    [string]$ReleaseNoteUri,

    [Parameter (Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [string]$EndOfLifeDate,

    [Parameter(Mandatory=$false)]
    [array]$ImageVersionTags,

    [Parameter(Mandatory=$false)]
    [array]$ImageDefinitionTags,

    [switch]$Clean
)

try {
    $endOfLifeDateIso = (Get-Date $EndOfLifeDate).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    Write-Host "endOfLifeDateIso=$endOfLifeDateIso"

    $imageId = $(az image list --resource-group $ResourceGroupName --query "[?contains(name, '$ImageName')].id | [0]" -o tsv)
    if ([string]::IsNullOrEmpty($imageId)) {
        Write-Host "##vso[task.logissue type=error]VM image id was null when retrieving the vm image information from resource group:'$ResourceGroupName' where image name contains:'$ImageName'"
        exit 1
    }
    Write-Host "Retrieved vm image information..."
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
        --release-note-uri $ReleaseNoteUri `
        --tags ${ImageDefinitionTags}) `
        | ConvertFrom-Json -Depth 10
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
        --end-of-life-date $endOfLifeDateIso `
        --tags ${ImageVersionTags}) `
        | ConvertFrom-Json -Depth 10
    if ($imageVersionResult.provisioningState -ne "Succeeded") {
        throw "Error while creating the image version. Provisioning did not succeed:" + ($imageDefinitionResult | Format-List | Out-String)
    }
    Write-Host ($imageVersionResult | Format-List | Out-String)

} catch {
    Write-Host "##vso[task.logissue type=error]There was an error creating the image definition and or the image version"
    Write-Host $_
} finally {
    if ($imageVersionResult.provisioningState -eq "Succeeded" -and $Clean) {
        Write-Host "Deleting vm managed image..."
        $deleteResult = $(az image delete --ids $imageId)
        Write-Host $deleteResult
    } else {
        Write-Host "##vso[task.logissue type=warning]Could not clean up the managed image. This could be due errors in access or the 'Clean' switch wasn't set."
    }
}
