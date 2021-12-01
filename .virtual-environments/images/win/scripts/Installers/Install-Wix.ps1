################################################################################
##  File:  Install-Wix.ps1
##  Desc:  Install WIX.
################################################################################

Choco-Install -PackageName wixtoolset -ArgumentList "--force"

<<<<<<< HEAD
Invoke-PesterTests -TestFile "Tools" -TestName "WiX"
=======
if (Test-IsWin19)
{
    $extensionUrl = "https://wixtoolset.gallerycdn.vsassets.io/extensions/wixtoolset/wixtoolsetvisualstudio2019extension/1.0.0.4/1563296438961/Votive2019.vsix"
    $VSver = "2019"
}
elseif (Test-IsWin16)
{
    $extensionUrl = "https://robmensching.gallerycdn.vsassets.io/extensions/robmensching/wixtoolsetvisualstudio2017extension/0.9.21.62588/1494013210879/250616/4/Votive2017.vsix"
    $VSver = "2017"
}

if (-not (Test-IsWin22))
{
    $extensionName = "Votive$VSver.vsix"

    #Installing VS extension 'Wix Toolset Visual Studio Extension'
    Install-VsixExtension -Url $extensionUrl -Name $extensionName -VSversion $VSver
}

Invoke-PesterTests -TestFile "Wix"
>>>>>>> 465bca504c21fc19e0cc7245e0ab7c0f1eac6000
