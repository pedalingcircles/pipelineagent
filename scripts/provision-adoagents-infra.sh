#!/bin/bash -e
##########################################################
##  File:  provision-adoagents-infra.sh
##  Desc:  Uses Bicep/ARM templates to provision ADO 
##         agent infrastructure. 
##########################################################

ORGANIZATION_NAME=$1
LOCATION=$2
SUBSCRIPTION=$3
ENVIRONMENT_TYPE=$4
TEMPLATE_FILE_PATH=$5
WHAT_IF=${6-0}

# print usage to the console
function usage() 
{
    echo "usage: installer-agent-extension.sh organization location subscription envtype templatefilepath"
    echo "  organization              The organization that's responsible for the agent workload"
    echo "  location                  The Azure region"
    echo "  subscription              The Azure subscription id"
    echo "  envtype                   The environment type"
    echo "  templatefilepath          The ARM/Bicep template file path"
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

if [ WHAT_IF -eq 0 ]; then
  echo "Running deployment operation"
  az deployment sub create \
    --name deploy-adoagent-baseline-$(date -u +"%Y%m%dT%H%M%SZ") \
    --no-prompt true \
    --location $LOCATION \
    --subscription $SUBSCRIPTION \
    --template-file $TEMPLATE_FILE_PATH \
    --parameters \
        environmentType=$ENVIRONMENT_TYPE \
        organization=$ORGANIZATION_NAME
else
  echo "Running what-if operation"
  az deployment sub what-if \
    --name deploy-adoagent-baseline-$(date -u +"%Y%m%dT%H%M%SZ") \
    --no-prompt true \
    --location $LOCATION \
    --subscription $SUBSCRIPTION \
    --template-file $TEMPLATE_FILE_PATH \
    --parameters \
        environmentType=$ENVIRONMENT_TYPE \
        organization=$ORGANIZATION_NAME
fi





