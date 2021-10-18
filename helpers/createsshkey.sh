#!/bin/bash

# This is a sample for generating an SSH keys (public/private) for agent
# machines. This task is not apart of the pipoelines themselves and is 
# done as a bootstrapping task before hand. These values can be managed
# ADO secure files or Azure key vault(s). 

ssh-keygen \
    -q \
    -m PEM \
    -t rsa \
    -N '' \
    -b 4096 \
    -C 'VM Agent Host' \
    -f ~/.ssh/vmagent-priv-key \
    <<< $'\ny' >/dev/null 2>&1