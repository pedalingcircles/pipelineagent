#!/bin/bash -e
################################################################################
##  File:  installer-agent-extension.sh
##  Desc:  Installs the Azure DevOps Agent. 
################################################################################

# Must be run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root. Exiting."
  exit 1
fi

AZP_AGENT_NAME=$1
AZP_POOL=$2
AZP_TOKEN=$3
AZP_URL=$4
AGENT_VERSION_TAG=${5-"latest"}
ASSET_NAME_PREFIX=${6-"pipelines-agent-linux-x64"}
GITHUB_API_ENDPOINT=${7-"https://api.github.com/repositories/53052789/releases"}
INSTALL_DIR=${8-"/opt/microsoft/azp"}

# Global variable used to download the agent software to the machine
AGENT_DOWNLOAD_URL=0

usage ()
{
    echo "Usage: installer-agent-extension.sh agentname poolname token adourl [agentversiontag] [assetprefix] [githubapiendpoint] [installdir]"
    echo "  agentname         The agent account name"
    echo "  poolname          The Agent Pool name"
    echo "  token             The Personal Access Token"
    echo "  adourl            The Azure DevOps organization URL"
    echo "  agentversiontag   The Azure Devops Agent version tag to download and install. Uses 'latest' if no version is given. e.g. 'v1.0.0'"
    echo "  assetprefix       The asset name prefix value used to identify the url needed in the assets.json file."
    echo "  githubapiendpoint The REST endpoint to get the release information from the  microsoft/azure-pipelines-agent repo"
    echo "  installdir        The installation directory for the agent software"
    exit 1
}

set_agent_download_url() 
{
  echo "Settings the agent download link based on version tag:'$AGENT_VERSION_TAG'"
  local version_tag="${AGENT_VERSION_TAG}"
  if [ "${AGENT_VERSION_TAG}" = "latest" ]; then
    echo "Finding the latest specific version since the version tag is set to 'latest'"
    version_tag=$(curl --silent --show-error --location "${GITHUB_API_ENDPOINT}/latest" | jq --raw-output '.tag_name')
    echo "Updated version tag to '$version_tag'"
  fi

  jq_filter=".[] | select(.tag_name | contains(\"$version_tag\")) | .assets[0].browser_download_url"
  browser_download_url=$(curl --silent --show-error $GITHUB_API_ENDPOINT | jq --raw-output "$jq_filter")
  echo "browser_download_url=$browser_download_url"

  jq_filter=".[] | select(.name | contains(\"$ASSET_NAME_PREFIX\")) | .downloadUrl"
  local agent_download_url=$(curl --silent --show-error --location $browser_download_url | jq --raw-output "$jq_filter")

  echo "agent_download_url=$agent_download_url"
  AGENT_DOWNLOAD_URL=$agent_download_url
}

if [ -z "$AZP_AGENT_NAME" ]; then
  usage
  echo 1>&2 "error: missing AZP_AGENT_NAME (1st argument) variable"
  exit 1
fi

if [ -z "$AZP_POOL" ]; then
  usage
  echo 1>&2 "error: missing AZP_POOL (2nd argument) variable"
  exit 1
fi

if [ -z "$AZP_TOKEN" ]; then
  usage
  echo 1>&2 "error: missing AZP_TOKEN (3rd argument) variable"
  exit 1
fi

if [ -z "$AZP_URL" ]; then
  usage
  echo 1>&2 "error: missing AZP_URL (4th argument) variable"
  exit 1
fi

mkdir --parents --verbose $INSTALL_DIR && cd $INSTALL_DIR
AZP_TOKEN_FILE=$INSTALL_DIR/.token
touch $AZP_TOKEN_FILE
echo -n $AZP_TOKEN > "$AZP_TOKEN_FILE"
echo "Created directory '$INSTALL_DIR'"

set_agent_download_url
echo "Downloading agent via URL '$AGENT_DOWNLOAD_URL'"
curl --show-error --location $AGENT_DOWNLOAD_URL | tar -xz
chown -R $AZP_AGENT_NAME $INSTALL_DIR

echo "Configuring agent (service) software..."
runuser $AZP_AGENT_NAME -c "${INSTALL_DIR}/config.sh --unattended --url $AZP_URL --auth pat --token $(cat "$AZP_TOKEN_FILE") --pool $AZP_POOL --acceptTeeEula" & wait $!
unset AZP_TOKEN

echo "Installing and starting the agent (service) software..."
./svc.sh install $AZP_AGENT_NAME
./svc.sh start $AZP_AGENT_NAME

exit 0