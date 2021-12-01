################################################################################
##  File:  Install-MysqlCli.ps1
##  Desc:  Install Mysql CLI
################################################################################

# Installing visual c++ redistibutable package.
$InstallerName = "vcredist_x64.exe"
$InstallerURI = "https://download.microsoft.com/download/0/5/6/056dcda9-d667-4e27-8001-8a0c6971d6b1/${InstallerName}"
$ArgumentList = ("/install", "/quiet", "/norestart")

Install-Binary -Url $InstallerURI -Name $InstallerName -ArgumentList $ArgumentList

## Downloading mysql
<<<<<<< HEAD
$MysqlMajorMinor = (Get-ToolsetContent).Mysql.version
$MysqlFullVersion = ((Invoke-WebRequest -Uri https://dev.mysql.com/downloads/mysql/${MysqlMajorMinor}.html).Content | Select-String -Pattern "${MysqlMajorMinor}\.\d+").Matches.Value
$MysqlVersionUrl = "https://dev.mysql.com/get/Downloads/MySQL-${MysqlMajorMinor}/mysql-${MysqlFullVersion}-winx64.zip"
=======
$MysqlMajorVersion = (Get-ToolsetContent).mysql.major_version
$MysqlFullVersion = (Get-ToolsetContent).mysql.full_version
$MysqlVersionUrl = "https://dev.mysql.com/get/Downloads/MySQL-${MysqlMajorVersion}/mysql-${MysqlFullVersion}-winx64.zip"
>>>>>>> 465bca504c21fc19e0cc7245e0ab7c0f1eac6000

$MysqlArchPath = Start-DownloadWithRetry -Url $MysqlVersionUrl -Name "mysql.zip"

# Expand the zip
Extract-7Zip -Path $MysqlArchPath -DestinationPath "C:\"

# Rename mysql-version to mysql folder
$MysqlPath = "C:\mysql"
<<<<<<< HEAD
Rename-Item -Path "C:\mysql-${MysqlFullVersion}-winx64" -NewName $MysqlPath
=======
Invoke-SBWithRetry -Command {
    Rename-Item -Path "C:\mysql-${MysqlFullVersion}-winx64" -NewName $MysqlPath -ErrorAction Stop
}
>>>>>>> 465bca504c21fc19e0cc7245e0ab7c0f1eac6000

# Adding mysql in system environment path
Add-MachinePathItem "${MysqlPath}\bin"

Invoke-PesterTests -TestFile "Databases" -TestName "MySQL"
