#!/bin/bash -e
################################################################################
##  File:  installer-agent-extension.sh
##  Desc:  Installs the Azure DevOps Agent. 
################################################################################

AZP_AGENT_NAME=$1
AZP_POOL=$2
AZP_TOKEN=$3
AZP_URL=$4
AGENT_VERSION=$5

function usage {
    echo "usage: installer-agent-extension.sh [agentname] [poolname] [token] [adourl] [agentversion]"
    echo "  agentname     The agent account name"
    echo "  poolname      The Agent Pool name"
    echo "  token         The Personal Access Token"
    echo "  adourl        The Azure DevOps organization URL"
    echo "  agentversion  The Azure Devops Agent version to download and isntall"
    exit 1
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

if [ -z "$AZP_TOKEN_FILE" ]; then
  if [ -z "$AZP_TOKEN" ]; then
    usage
    echo 1>&2 "error: missing AZP_TOKEN (3rd argument) variable"
    exit 1
  fi
fi

if [ -z "$AZP_URL" ]; then
  usage
  echo 1>&2 "error: missing AZP_URL (4th argument) variable"
  exit 1
fi

if [ -z "$AGENT_VERSION" ]; then
  usage
  echo 1>&2 "error: missing AGENT_VERSION (5th argument) variable"
  exit 1
fi

# download ADO agent
mkdir -p /opt/azp && cd /opt/azp

AZP_TOKEN_FILE=/opt/azp/.token
touch $AZP_TOKEN_FILE
echo -n $AZP_TOKEN > "$AZP_TOKEN_FILE"
unset AZP_TOKEN

curl -LsS https://vstsagentpackage.azureedge.net/agent/${AGENT_VERSION}/vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz | tar -xz

chown -R $AZP_AGENT_NAME /opt/azp

#runuser -l $AZP_AGENT_NAME -c "/opt/azp/config.sh \
runuser $AZP_AGENT_NAME -c "/opt/azp/config.sh \
    --unattended \
    --url $AZP_URL \
    --auth PAT \
    --token $(cat "$AZP_TOKEN_FILE") \
    --pool $AZP_POOL \
    --acceptTeeEula" & wait $!

# # install and start the service
./svc.sh install $AZP_AGENT_NAME
./svc.sh start $AZP_AGENT_NAME

exit 0