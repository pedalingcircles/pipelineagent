
# Setting up Service Principals and Service Connections

Setting up and configuring a service connection with the corresponding App Registration / Service Principal along with the proper RBAC and Groups is critical to managing and governing Azure Pipelines at scale.

# Role Based Access Control (RBAC)

Determine what role you want to assign the service principal. Use the [principle of least priviledge](https://en.m.wikipedia.org/wiki/Principle_of_least_privilege). These roles depend on what the pipeline will be allowed to perform since they are associated and managed by the underling Service Connections. Leverage Groups to manage various identities including Service Principals at scale.

under a specific application pool. The following are some common things to consider:

- Creation and tear-down of resource groups
- Provision and remove resources at a specific scope, typically at the subscription or resource group level
- Environment longevity: static vs. ephemeral environments
- Granularity of subscriptions and resource groups
- Cost management

The process of what level of access is needed and is planned closely with
the delivery team of the app. Least proviledge will likely mean different things
in the various environments the pipelines will be using. For example, a pipeline may need to
create and tear down resource groups at will to support developers and pull requests.
However, high level subscriptions such as staging and production may have more restrictions
such as not allowing the pipeline to create resource groups.

# Creating the service principal and service connection

You will need to have the correct priveledge in both the Azure AD tenant and the subscription. Review
the [createserviceprincipal.sh](../helpers/createserviceprincipal.sh) script for an example on creating
the app registration, service principal, certificate, and service connection.

## Create a self signed certificate

``` bash
openssl.exe req -x509 -nodes -sha256 -days 3650 -subj "/CN=Local" -newkey rsa:2048 -keyout Local.key -out Local.crt
```

# See also

[Manage service connections](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml)

[Connect to Microsoft Azure](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/connect-to-azure?view=azure-devops)

[Use Azure PowerShell to create a service principal with a certificate](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-authenticate-service-principal-powershell)

[X.509](https://en.wikipedia.org/wiki/X.509)

[Create an Azure service principal with the Azure CLI](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli)

[Azure DevOps CLI service endpoint](https://docs.microsoft.com/en-us/azure/devops/cli/service-endpoint?view=azure-devops)

## Distinguished Names

[LDAP : Distinguished Names](https://docs.microsoft.com/en-us/previous-versions/windows/desktop/ldap/distinguished-names)

[DigiCert : What is a Distinguished Name (DN)?](https://knowledge.digicert.com/generalinformation/INFO1745.html)

[Cryptography : Distinguished Name Fields](https://docs.microsoft.com/en-us/windows/win32/seccrypto/distinguished-name-fields)

## Certificates

[Wikipedia : PKCS 12](https://en.wikipedia.org/wiki/PKCS_12)

[https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli]
