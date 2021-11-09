#!/bin/bash -e
################################################################################
##  File:  installer-agent-extension.sh
##  Desc:  Installs the Azure DevOps Agent. 
################################################################################

# Constants
ASSET_NAME_PREFIX=pipelines-agent-linux-x64
GITHUB_API_ENDPOINT=https://api.github.com/repositories/53052789/releases
INSTALL_DIR=/opt/microsoft/azp

# Must be run as sudo
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

AZP_AGENT_NAME=$1
AZP_POOL=$2
AZP_TOKEN=$3
AZP_URL=$4
AGENT_VERSION_TAG=${5-"latest"}

usage () 
{
    echo "usage: installer-agent-extension.sh [agentname] [poolname] [token] [adourl] [agentversion]"
    echo "  agentname     The agent account name"
    echo "  poolname      The Agent Pool name"
    echo "  token         The Personal Access Token"
    echo "  adourl        The Azure DevOps organization URL"
    echo "  agentversiontag  The Azure Devops Agent version tag to download and install. Uses 'latest' if no version is given. e.g. 'v1.0.0'"
    exit 1
}

get_agent_download_url() 
{
  local version_tag="${AGENT_VERSION_TAG}"
  if [ "${AGENT_VERSION_TAG}" = "latest" ]; then
    version_tag=$(curl --silent --show-error --location "${GITHUB_API_ENDPOINT}/latest" | jq --raw-output '.tag_name')
  fi

  jq_filter=".[] | select(.tag_name | contains(\"$version_tag\")) | .assets[0].browser_download_url"
  browser_download_url=$(curl --silent --show-error $GITHUB_API_ENDPOINT | jq --raw-output "$jq_filter")
  jq_filter=".[] | select(.name | contains(\"$ASSET_NAME_PREFIX\")) | .downloadUrl"
  local agent_download_url=$(curl --silent --show-error --location $browser_download_url | jq --raw-output "$jq_filter")

  # return value to stdout
  echo $agent_download_url
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
unset AZP_TOKEN
echo "Created directory $INSTALL_DIR"

agent_download_url=$(get_agent_download_url)
echo "Downloading agent via link:$agent_download_url"
curl --show-error --location $agent_download_url | tar -xz
chown -R $AZP_AGENT_NAME $INSTALL_DIR

# if [ "$AGENT_VERSION" = "latest" ]; then
#   echo "Agent version argument is $AGENT_VERSION: Finding current latest version from https://api.github.com/repositories/53052789/releases/latest"
#   curl -s https://api.github.com/repositories/53052789/releases/latest | jq -r .assets[].browser_download_url

#   agent_url=(jq --raw-output '[?contains(name, `pipelines-agent-linux-x64`) == `true`].downloadUrl | [0]' assets.json)
#   echo "Using URL '$agent_url' to download latest agent version based on OS specification pipelines-agent-linux-x64"
# else
#   agent_url="https://vstsagentpackage.azureedge.net/agent/${AGENT_VERSION}/vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz"
#   echo "Agent version argument is $AGENT_VERSION: Directly downloading from '$agent_url'"
# fi

echo "Configure agent (service) software..."
# https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/v2-linux?view=azure-devops#unattended-config
runuser $AZP_AGENT_NAME -c "${INSTALL_DIR}/config.sh" \
    --unattended \
    --url $AZP_URL \
    --auth PAT \
    --token $(cat "$AZP_TOKEN_FILE") \
    --pool $AZP_POOL \
    --acceptTeeEula" & wait $!

echo "Install and start the agent (service) software..."
./svc.sh install $AZP_AGENT_NAME
./svc.sh start $AZP_AGENT_NAME

exit 0