
# https://gist.github.com/JasonFreeberg/c860df6e1aa0fe423cba86e94577adab


#!/bin/bash
agentuser=${AGENT_USER}
pool=${AGENT_POOL}
pat=${AGENT_TOKEN}
azdourl=${AZDO_URL}

# install az cli
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# download azdo agent
mkdir -p /opt/azdo && cd /opt/azdo
cd /opt/azdo
curl -o azdoagent.tar.gz https://vstsagentpackage.azureedge.net/agent/2.179.0/vsts-agent-linux-x64-2.179.0.tar.gz  # Newer versions may be available at the time you're reading this
tar xzvf azdoagent.tar.gz
rm -f azdoagent.tar.gz

# configure as azdouser
chown -R $agentuser /opt/azdo
chmod -R 755 /opt/azdo
runuser -l $agentuser -c "/opt/azdo/config.sh --unattended --url $azdourl --auth pat --token $pat --pool $pool --acceptTeeEula"

# install and start the service
./svc.sh install
./svc.sh start