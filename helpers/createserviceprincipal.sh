#!/bin/bash
# Create a service principle 
# and a certificate to be used in ADO.

# This script uses openssl, Azure CLI, the Azure DevOps extension, and jq
# https://www.openssl.org/
# https://docs.microsoft.com/en-us/cli/azure/
# https://github.com/Azure/azure-devops-cli-extension
# https://stedolan.github.io/jq/
#
# https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli

# Create a service principle with a certificate. You have three options:
#   1. Create with an existing certificate (PEM): 
#       az ad sp create-for-rbac --name ServicePrincipalName --cert "-----BEGIN CERTIFICATE-----...-----END CERTIFICATE-----"
#       or
#       az ad sp create-for-rbac --name ServicePrincipalName --cert @/path/to/cert.pem
#
#   2. Create with an exsting certificate from key vault: 
#       az ad sp create-for-rbac --name ServicePrincipalName --cert CertName --keyvault VaultName
#
#   3. Create with a self-signed certificate that's generated automatically:
#       az ad sp create-for-rbac --name ServicePrincipalName --create-cert

serviceConnectionName=$1
aadGroupName=$2
adoOrganizationUrl=$3
adoProject=$4
subscriptionTenantId=$5
subscriptionId=$6
subscriptionName=$7
adoTenantId=$8

# Login to the target tenent that resources will be created in
az login --tenant $subscriptionTenantId

spResult=$(az ad sp create-for-rbac --name $serviceConnectionName --role "Reader" --create-cert)
appId=$(echo $spResult | jq -r ".appId")
certPath=$(echo $spResult | jq -r ".fileWithCertAndPrivateKey")
displayName=$(echo $spResult | jq -r ".displayName")
sleep 5

# get service principle object id
spObjectId=$(az ad sp list --display-name $serviceConnectionName --query "[].objectId" --output tsv)

# Adding the service principal to a group
az ad group member add --group "$aadGroupName" --member-id $spObjectId

sleep 20

# Login to ADO tenant that is running the pipelines
az login --tenant $adoTenantId

# Setting the default ADO project to create the service connection in
az devops configure --defaults organization=$adoOrganizationUrl project=$adoProject

# Notes: 
# The azure-rm-service-principal-id is the appId of the App Registration and not the service principle Object ID
# The tenant ID is the home tenant of where the app id is created
az devops service-endpoint azurerm create \
    --azure-rm-service-principal-id $appId \
    --azure-rm-subscription-id $subscriptionId \
    --azure-rm-subscription-name "$subscriptionName" \
    --azure-rm-tenant-id $subscriptionTenantId \
    --name "$serviceConnectionName" \
    --azure-rm-service-principal-certificate-path $certPath

# remove pem ?

echo completed
