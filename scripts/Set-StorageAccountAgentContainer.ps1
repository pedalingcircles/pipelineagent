$newItemResult = New-Item -Path "c:/temp/scriptextensions" -Name "deploy-agent-virtualmachine-20211021T172233Z" -ItemType "directory"
$copyItemResult = Copy-Item -Path "C:\Users\mijohns\Source\repos\byvrate\pipelineagent\iac\scripts\agentinstall\*" -Destination "c:/temp/scriptextensions/deploy-agent-virtualmachine-20211021T172233Z" -Recurse


# land files

# create directory (locally) based on deployment name
# copy files into that directory
# upload that folder



az storage blob upload-batch `
    --destination scriptextensions `
    --source c:/temp/scriptextensions `
    --account-name stagentpasbxu63kxyluy6fd `
    --auth-mode login


#tear down after

