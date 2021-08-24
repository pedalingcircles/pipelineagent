#!/bin/bash

echo 'Start agent script extension'

agentuser=${AGENT_USER}
pool=${AGENT_POOL}
pat=${AGENT_TOKEN}
adourl=${ADO_URL}

# install az cli
# Already installed on the preconfigured images
#curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

pwd

# download ado agent
mkdir -p /opt/ado && cd /opt/ado

pwd

curl -o adoagent.tar.gz https://vstsagentpackage.azureedge.net/agent/2.190.0/vsts-agent-linux-x64-2.190.0.tar.gz
tar xzvf adoagent.tar.gz
rm -f adoagent.tar.gz

# configure as adouser
chown -R $agentuser /opt/ado
chmod -R 755 /opt/ado
runuser -l $agentuser -c "/opt/ado/config.sh --unattended --url $adourl --auth pat --token $pat --pool $pool --acceptTeeEula"

# install and start the service
./svc.sh install
./svc.sh start

exit 0