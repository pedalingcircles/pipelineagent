
#!/bin/bash -e
################################################################################
##  File:  installer-agent-extension.sh
##  Desc:  Uploads script files to an Azure storage account blob container
################################################################################

STORAGE_ACCOUNT_NAME=$1
CONTAINER_NAME=$2
INSTALL_DIRECTORY=$3
AGENT_INSTALLER_SOURCE_PATH=$4

function usage {
    echo "usage: installer-agent-extension.sh [storageaccount] [container] [installdirectory] [agentinstallsourcepath]"
    echo "  storageaccount          The storage account name to upload files to"
    echo "  container               The storage container to upload files to"
    echo "  installdirectory        The directory to upload files to within the container"
    echo "  agentinstallsourcepath  The source path of the file to upload"
    exit 1
}

if [ -z "$STORAGE_ACCOUNT_NAME" ]; then
  usage
  echo 1>&2 "##vso[task.logissue type=error]missing STORAGE_ACCOUNT_NAME (1st argument) variable"
  exit 1
fi

if [ -z "$CONTAINER_NAME" ]; then
  usage
  echo 1>&2 "##vso[task.logissue type=error]missing CONTAINER_NAME (2nd argument) variable"
  exit 1
fi

if [ -z "$INSTALL_DIRECTORY" ]; then
  usage
  echo 1>&2 "##vso[task.logissue type=error]missing INSTALL_DIRECTORY (3rd argument) variable"
  exit 1
fi
      
if [ -z "$AGENT_INSTALLER_SOURCE_PATH" ]; then
  usage
  echo 1>&2 "##vso[task.logissue type=error]missing AGENT_INSTALLER_SOURCE_PATH (4th argument) variable"
  exit 1
fi

az storage blob upload-batch \
    --destination $CONTAINER_NAME/$INSTALL_DIRECTORY \
    --source $AGENT_INSTALLER_SOURCE_PATH \
    --account-name $STORAGE_ACCOUNT_NAME \
    --auth-mode login
