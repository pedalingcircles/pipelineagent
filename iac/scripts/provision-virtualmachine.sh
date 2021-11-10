
#!/bin/bash -e
################################################################################
##  File:  provision-virtualmachine.sh
##  Desc:  Uses Azure CLI to call a bicep file (template) to provision VM(s)
################################################################################

ORGANIZATION_NAME=$1
LOCATION=$2
SUBSCRIPTION=$3
ENVIRONMENT_TYPE=$4
TEMPLATE_FILE_PATH=$5
SSH_PUBLICKEY_FILE_PATH=$6
AGENT_RESOURCEGROUP_NAME=$7
IMAGE_RESOURCEGROUP_NAME=$8
SHARED_IMAGEGALLERY_NAME=$9
IMAGE_DEFINITION_NAME=${10}
IMAGE_DEFINITION_VERSION=${11}
NETWORK_SECURITYGROUP_NAME=${12}
VNET_NAME=${13}
SUBNET_NAME=${14}
STORAGEACCOUNT_NAME=${15}
CONTAINER_NAME=${16}
INSTALL_DIRECTORY=${17}
AGENT_POOL=${18}
PAT=${19}
ORG_URL=${20}

# print usage to the console
function usage() 
{
    echo "usage: installer-agent-extension.sh organization location subscription envtype templatefilepath sshpublickeypath agentresourcegroupname imageresourcegroupname sharedgalleryname imagedefinition imagedefinitionversion networksecuritygroup vnet subnet storageaccount container installdirectory agentpool pat orgurl"
    echo "  organization              The organization that's responsible for the agent workload"
    echo "  location                  The Azure region"
    echo "  subscription              The Azure subscription id"
    echo "  envtype                   The environment type"
    echo "  templatefilepath          The ARM/Bicep template file path"
    echo "  sshpublickeypath          The SSH public key path"
    echo "  agentresourcegroupname    The image resource group name"
    echo "  imageresourcegroupname    The image resource group name"
    echo "  sharedgalleryname         The Shared Image Gallery name"
    echo "  imagedefinition           The image definition name"
    echo "  imagedefinitionversion    The image definition version"
    echo "  networksecuritygroup      The network security group name"
    echo "  vnet                      The virtual network name"
    echo "  subnet                    The subnet name"
    echo "  storageaccount            The storage account name"
    echo "  container                 The storage account container name"
    echo "  installdirectory          The directory inside the storage container where the agent install scripts are located"
    echo "  agentpool                 The Azure DevOps (ADO) agent pool name"
    echo "  pat                       The personal access token"
    echo "  orgurl                    The Azure DevOps (ADO) organization URL"
    exit 1
}

if [ -z "$ORGANIZATION_NAME" ]; then
  usage
  echo 1>&2 "##vso[task.logissue type=error]missing ORGANIZATION_NAME (1st argument) variable"
  exit 1
fi

if [ -z "$LOCATION" ]; then
  usage
  echo 1>&2 "##vso[task.logissue type=error]missing LOCATION (2nd argument) variable"
  exit 1
fi

if [ -z "$SUBSCRIPTION" ]; then
  usage
  echo 1>&2 "##vso[task.logissue type=error]missing SUBSCRIPTION (3rd argument) variable"
  exit 1
fi
      
if [ -z "$ENVIRONMENT_TYPE" ]; then
  usage
  echo 1>&2 "##vso[task.logissue type=error]missing ENVIRONMENT_TYPE (4th argument) variable"
  exit 1
fi

if [ -z "$TEMPLATE_FILE_PATH" ]; then
  usage
  echo 1>&2 "##vso[task.logissue type=error]missing TEMPLATE_FILE_PATH (5th argument) variable"
  exit 1
fi

if [ -z "$SSH_PUBLICKEY_FILE_PATH" ]; then
  usage
  echo 1>&2 "##vso[task.logissue type=error]missing SSH_PUBLICKEY_FILE_PATH (6th argument) variable"
  exit 1
fi

if [ -z "$AGENT_RESOURCEGROUP_NAME" ]; then
  usage
  echo 1>&2 "##vso[task.logissue type=error]missing AGENT_RESOURCEGROUP_NAME (7th argument) variable"
  exit 1
fi

if [ -z "$IMAGE_RESOURCEGROUP_NAME" ]; then
  usage
  echo 1>&2 "##vso[task.logissue type=error]missing IMAGE_RESOURCEGROUP_NAME (8th argument) variable"
  exit 1
fi

if [ -z "$SHARED_IMAGEGALLERY_NAME" ]; then
  usage
  echo 1>&2 "##vso[task.logissue type=error]missing SHARED_IMAGEGALLERY_NAME (9th argument) variable"
  exit 1
fi

if [ -z "$IMAGE_DEFINITION_NAME" ]; then
  usage
  echo 1>&2 "##vso[task.logissue type=error]missing IMAGE_DEFINITION_NAME (10th argument) variable"
  exit 1
fi

if [ -z "$IMAGE_DEFINITION_VERSION" ]; then
  usage
  echo 1>&2 "##vso[task.logissue type=error]missing IMAGE_DEFINITION_VERSION (11th argument) variable"
  exit 1
fi

if [ -z "$NETWORK_SECURITYGROUP_NAME" ]; then
  usage
  echo 1>&2 "##vso[task.logissue type=error]missing NETWORK_SECURITYGROUP_NAME (12th argument) variable"
  exit 1
fi

if [ -z "$VNET_NAME" ]; then
  usage
  echo 1>&2 "##vso[task.logissue type=error]missing VNET_NAME (13th argument) variable"
  exit 1
fi

if [ -z "$SUBNET_NAME" ]; then
  usage
  echo 1>&2 "##vso[task.logissue type=error]missing SUBNET_NAME (14th argument) variable"
  exit 1
fi

if [ -z "$STORAGEACCOUNT_NAME" ]; then
  usage
  echo 1>&2 "##vso[task.logissue type=error]missing STORAGEACCOUNT_NAME (15th argument) variable"
  exit 1
fi

if [ -z "$CONTAINER_NAME" ]; then
  usage
  echo 1>&2 "##vso[task.logissue type=error]missing CONTAINER_NAME (16th argument) variable"
  exit 1
fi

if [ -z "$INSTALL_DIRECTORY" ]; then
  usage
  echo 1>&2 "##vso[task.logissue type=error]missing INSTALL_DIRECTORY (17th argument) variable"
  exit 1
fi

if [ -z "$AGENT_POOL" ]; then
  usage
  echo 1>&2 "##vso[task.logissue type=error]missing AGENT_POOL (18th argument) variable"
  exit 1
fi

if [ -z "$PAT" ]; then
  usage
  echo 1>&2 "##vso[task.logissue type=error]missing PAT (19th argument) variable"
  exit 1
fi

if [ -z "$ORG_URL" ]; then
  usage
  echo 1>&2 "##vso[task.logissue type=error]missing ORG_URL (20th argument) variable"
  exit 1
fi

blobnames=$(az storage blob list \
  --container-name $CONTAINER_NAME \
  --account-name $STORAGEACCOUNT_NAME \
  --auth-mode login \
  --prefix $INSTALL_DIRECTORY \
  --query "[].name" --out tsv)

if [ ${#blobnames[@]} -eq 0 ]; then
  echo 1>&2 "##vso[task.logissue type=error]could not find any blob names in '$STORAGEACCOUNT_NAME' storage account with path '$CONTAINER_NAME/$INSTALL_DIRECTORY'"
  exit 1
fi

# empty array to be populated by full blob urls 
script_extensions_scripturis=()

# Hard coding a short duration for expiry since
# we only need it during deployment time
end_expiry=`date -u -d "30 minutes" '+%Y-%m-%dT%H:%MZ'`

for blob_name in ${blobnames[@]}; do
  blob_url=$(az storage blob url \
    --container-name $CONTAINER_NAME \
    --name $blob_name \
    --account-name $STORAGEACCOUNT_NAME \
    --auth-mode login \
    --protocol https \
    -o tsv)

  blob_sastoken=$(az storage blob generate-sas \
    --account-name $STORAGEACCOUNT_NAME \
    --auth-mode login \
    --as-user \
    --container-name $CONTAINER_NAME \
    --name $blob_name \
    --permissions r \
    --expiry $end_expiry \
    --https-only \
    -o tsv)

  # Adding to the array, but we need extra quotes due 
  # to the formatting of passing an "array" via Azure CLI
  script_extensions_scripturis+=("\"${blob_url}?${blob_sastoken}\"")
  unset blob_sastoken
  echo "added script url for blob '$blob_name' to array"
done

public_key=$(cat "$SSH_PUBLICKEY_FILE_PATH")

echo $(IFS=, ; printf "(%s)" "${script_extensions_scripturis[*]}")

az deployment group create \
  --resource-group $AGENT_RESOURCEGROUP_NAME \
  --name agentVmDeployment \
  --no-prompt true \
  --subscription $SUBSCRIPTION \
  --template-file $TEMPLATE_FILE_PATH \
  --parameters \
      environmentType=$ENVIRONMENT_TYPE \
      organization=$ORGANIZATION_NAME \
      resourceGroupName=$AGENT_RESOURCEGROUP_NAME \
      adminPublicKey="$public_key" \
      agentPool="$AGENT_POOL" \
      pat=$PAT \
      orgUrl=$ORG_URL \
      existingSharedImageGalleryName=$SHARED_IMAGEGALLERY_NAME \
      existingImageResourceGroupName=$IMAGE_RESOURCEGROUP_NAME \
      imageDefinitionName=$IMAGE_DEFINITION_NAME \
      imageDefinitionVersion=$IMAGE_DEFINITION_VERSION \
      existingNetworkSecurityGroupName=$NETWORK_SECURITYGROUP_NAME \
      existingVnetName=$VNET_NAME \
      existingSubnetName=$SUBNET_NAME \
      existingStorageAccountName=$STORAGEACCOUNT_NAME \
      scriptExtensionScriptUris=$(IFS=, ; printf "(%s)" "${script_extensions_scripturis[*]}")

unset public_key