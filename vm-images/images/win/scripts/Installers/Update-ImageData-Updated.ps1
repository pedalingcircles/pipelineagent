
<#
.Synopsis
    Creates an image data file based on agent meta data.
.DESCRIPTION
    Creates an image data file based on agent meta data associated to the image platform.  
    
    The meta data in this file will show up in the "Initialize job" step during a job run. 
    The specific information to capture is the "Operating System" group and  the "Virtual Environment"
    group.

.NOTES
    This file is based on the Update-ImageData.ps1 script which comes from
    the actions/virtual-environments repository. This script replaces that script
    when building custom Packer images. 
#>

$os = Get-CimInstance -ClassName Win32_OperatingSystem
$caption = $os.Caption
$osName = $caption.Substring(0, $caption.LastIndexOf(" "))
$osEdition = $caption.Substring($caption.LastIndexOf(" ")+1)
$osVersion = $os.Version
$imageVersion = $env:IMAGE_VERSION
$imageDataFile = $env:IMAGEDATA_FILE
$softwareUrl = $env:SOFTWARE_URL
$releaseUrl = $env:RELEASE_URL

if (Test-IsWin22) {
    $imageLabel = "windows-2022"
} elseif (Test-IsWin19) {
    $imageLabel = "windows-2019"
} elseif (Test-IsWin16) {
    $imageLabel = "windows-2016"
} else {
    throw "Invalid platform version is found. Either Windows Server 2016 or 2019 or 2022 are required"
}

$json = @"
[
  {
    "group": "Operating System",
    "detail": "${osName}\n${osVersion}\n${osEdition}"
  },
  {
    "group": "Virtual Environment",
    "detail": "Environment: ${imageLabel}\nVersion: ${imageVersion}\nIncluded Software: ${softwareUrl}\nImage Release: ${releaseUrl}"
  }
]
"@

$json | Out-File -FilePath $imageDataFile

# Set static env vars
setx ImageVersion $env:IMAGE_VERSION /m
setx ImageOS $env:IMAGE_OS /m
setx AGENT_TOOLSDIRECTORY $env:AGENT_TOOLSDIRECTORY /m