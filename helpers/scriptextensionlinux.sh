#!/bin/bash
set -e

AZP_AGENT_NAME=$1
AZP_POOL=$2
AZP_TOKEN=$3
AZP_URL=$4
AGENT_VERSION=$5

if [ -z "$AZP_AGENT_NAME" ]; then
  echo 1>&2 "error: missing AZP_AGENT_NAME (1st argument) variable"
  exit 1
fi

if [ -z "$AZP_POOL" ]; then
  echo 1>&2 "error: missing AZP_POOL (2nd argument) variable"
  exit 1
fi

if [ -z "$AZP_TOKEN_FILE" ]; then
  if [ -z "$AZP_TOKEN" ]; then
    echo 1>&2 "error: missing AZP_TOKEN (3rd argument) variable"
    exit 1
  fi
fi

if [ -z "$AZP_URL" ]; then
  echo 1>&2 "error: missing AZP_URL (4th argument) variable"
  exit 1
fi

if [ -z "$AGENT_VERSION" ]; then
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

# Let the agent ignore the token env variables
export VSO_AGENT_IGNORE=AZP_TOKEN,AZP_TOKEN_FILE

source ./env.sh

echo "Configure agent..."
./config.sh --unattended \
  --agent "${AZP_AGENT_NAME:-$(hostname)}" \
  --url "$AZP_URL" \
  --auth PAT \
  --token $(cat "$AZP_TOKEN_FILE") \
  --pool "${AZP_URL:-Default}" \
  --work "${AZP_WORK:-_work}" \
  --replace \
  --acceptTeeEula & wait $!











#curl -o adoagent.tar.gz https://vstsagentpackage.azureedge.net/agent/${AGENT_VERSION}/vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz
#tar xzvf adoagent.tar.gz
#rm -f adoagent.tar.gz

# configure as adouser
#chown -R $agentuser /opt/azp
#chmod -R 755 /opt/azp
#runuser -l $agentuser -c "/opt/azp/config.sh --unattended --url $adourl --auth pat --token $pat --pool $pool --acceptTeeEula" & wait $!

# install and start the service
# ./svc.sh install
# ./svc.sh start

exit 0