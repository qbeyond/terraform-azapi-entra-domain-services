# Entra Domain Services
[![GitHub tag](https://img.shields.io/github/tag/qbeyond/terraform-azapi-entra-domain-services.svg)](https://registry.terraform.io/modules/qbeyond/entra-domain-services/azapi/latest)
[![License](https://img.shields.io/github/license/qbeyond/terraform-azapi-entra-domain-services.svg)](https://github.com/qbeyond/terraform-azapi-entra-domain-services/blob/main/LICENSE)

----

Module to deploy entra domain services (former Azure Active Directory Domain Services). This module will create an entra domain services, a service principal 'Domain Services', a group AADC Administratos in Entra ID and an administrative account in that group.

<!-- BEGIN_TF_DOCS -->
## Usage

```hcl
provider "azurerm" {
  features {}

  skip_provider_registration = true
}

resource "azurerm_resource_group" "deploy" {
  name     = "example-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "deploy" {
  name                = "deploy-vnet"
  location            = azurerm_resource_group.deploy.location
  resource_group_name = azurerm_resource_group.deploy.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "deploy" {
  name                 = "deploy-subnet"
  resource_group_name  = azurerm_resource_group.deploy.name
  virtual_network_name = azurerm_virtual_network.deploy.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "deploy" {
  name                = "deploy-nsg"
  location            = azurerm_resource_group.deploy.location
  resource_group_name = azurerm_resource_group.deploy.name
}

resource "azurerm_subnet_network_security_group_association" "deploy" {
  subnet_id                 = azurerm_subnet.deploy.id
  network_security_group_id = azurerm_network_security_group.deploy.id
}

resource "azurerm_resource_group" "aadds" {
  name     = "aadds-rg"
  location = "westeurope"
}

module "entra_domain_services" {
  source = "../.."

  domain                 = "example.onmicrosoft.com"
  aaddc_admin_password   = "S3curePassword!"
  subnet                 = azurerm_subnet.deploy
  notification_settings  = {}
  ldaps_settings         = null
  location               = "West Europe"
  resource_group_id      = azurerm_resource_group.aadds.id
  network_security_group = azurerm_network_security_group.deploy
}
```

More examples in examples folder!

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.5.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | >= 1.0.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | >= 2.48.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.49.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aaddc_admin_password"></a> [aaddc\_admin\_password](#input\_aaddc\_admin\_password) | The password assigned to the domain admin fct\_aadc\_admin@domain. | `string` | n/a | yes |
| <a name="input_domain"></a> [domain](#input\_domain) | The domain name for the Entra Domain Services. Domain must either be the tenant's domain or a custom domain verified in EID | `string` | n/a | yes |
| <a name="input_ldaps_settings"></a> [ldaps\_settings](#input\_ldaps\_settings) | Configure LDAPS. To disable LDAPS, set the configuration to `null`.<pre>externalAccess: A flag to determine whether or not Secure LDAP access over the internet is enabled or disabled.	<br>  pfxCertificate: Base64encoded representation certificate required to configure Secure LDAP.<br>  pfxCertificatePassword: The password to decrypt the provided Secure LDAP certificate pfx file.</pre> | <pre>object({<br>    externalAccess         = optional(bool, false)<br>    pfxCertificate         = string<br>    pfxCertificatePassword = string<br>  })</pre> | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The location of the resources. | `string` | n/a | yes |
| <a name="input_network_security_group"></a> [network\_security\_group](#input\_network\_security\_group) | The nsg associated to the provided subnet. The nsg must not contain any rules defined inline in the nsg resource block. | <pre>object({<br>    id                  = string<br>    name                = string<br>    resource_group_name = string<br>    security_rule = optional(list(object({<br>      name = string<br>    })), [])<br>  })</pre> | n/a | yes |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | Id of the resource group where the resources will be created. | `string` | n/a | yes |
| <a name="input_subnet"></a> [subnet](#input\_subnet) | The subnet to deploy Entra DS to. | <pre>object({<br>    id = string<br>  })</pre> | n/a | yes |
| <a name="input_domain_configuration_type"></a> [domain\_configuration\_type](#input\_domain\_configuration\_type) | The configuration type of this Active Directory Domain. | `string` | `"FullySynced"` | no |
| <a name="input_filtered_sync"></a> [filtered\_sync](#input\_filtered\_sync) | Enabled or Disabled flag to turn on Group-based filtered sync | `bool` | `true` | no |
| <a name="input_notification_settings"></a> [notification\_settings](#input\_notification\_settings) | Choose who should get email alerts for issues affecting this managed domain.<pre>additionalRecipients: A list of email addresses of additional receipients.<br>    notifyAADDCAdmins: Choose wether or not members of the Entra ID group AAD DC Administrators should be notified.<br>    notifyGlobalAdmins: Choose wether or not accounts with Entra ID role 'global admin' should be notified.</pre> | <pre>object({<br>    additionalRecipients = optional(list(string), [])<br>    notifyAADDCAdmins    = optional(bool, true)<br>    notifyGlobalAdmins   = optional(bool, true)<br>  })</pre> | `{}` | no |
| <a name="input_security_settings"></a> [security\_settings](#input\_security\_settings) | <pre>channelBinding: Require all LDAP clients to provide channel binding information when communicating with the directory. Any client that does not provide this information will fail.<br>  kerberosArmoring: Enable or disable Kerberos Armoring for your managed domain. This will provide a protected channel between the Kerberos client and the KDC.<br>  kerberosRc4Encryption: Enable or disable Kerberos RC4 encryption for your managed domain. When Kerberos RC4 encryption is disabled, all Kerberos requests that use RC4 encryption will fail.<br>  ldapSigning: Require all LDAP clients to request signing during bind time. Any bind request that does not request signing will fail.<br>  ntlmV1: Enable or disable NTLM v1 authentication for your managed domain. When NTLM v1 authentication is disabled, all NTLM v1 authentication requests will fail.<br>  syncKerberosPasswords: Enable or disable Kerberos password hash synchronization. When this is disabled, synchronized user accounts will be unable to use Kerberos authentication in the managed domain.<br>  syncNtlmPasswords: Enable or disable NTLM password hash synchronization. When this is disabled, synchronized user accounts will be unable to use NTLM authentication in the managed domain.<br>  syncOnPremPasswords: Enable or disable password hash synchronization for on-premises accounts. When this is disabled, on-premises user accounts will be unable to authenticate in the managed domain. Cloud-only users will be unaffected.<br>  tlsV1: Enable or disable TLS 1 legacy mode for your managed domain.</pre> | <pre>object({<br>    channelBinding        = optional(bool, true)<br>    kerberosArmoring      = optional(bool, true)<br>    kerberosRc4Encryption = optional(bool, false)<br>    ldapSigning           = optional(bool, true)<br>    ntlmV1                = optional(bool, false)<br>    syncKerberosPasswords = optional(bool, true)<br>    syncNtlmPasswords     = optional(bool, false)<br>    syncOnPremPasswords   = optional(bool, true)<br>    tlsV1                 = optional(bool, false)<br>  })</pre> | `{}` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | The SKU for the Entra Domain Services (Standard/Enterprise/Premium). | `string` | `"Enterprise"` | no |
| <a name="input_sync_scope"></a> [sync\_scope](#input\_sync\_scope) | All users including synced users from on prem are synced into the AAD DS domain or only users originated in the cloud. | `string` | `"CloudOnly"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags that will be set on every resource this module creates. | `map(string)` | `{}` | no |
## Outputs

No outputs.

      ## Resource types

      | Type | Used |
      |------|-------|
        | [azapi_resource](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | 1 |
        | [azuread_group](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group) | 1 |
        | [azuread_service_principal](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | 1 |
        | [azurerm_network_security_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | 10 |

      **`Used` only includes resource blocks.** `for_each` and `count` meta arguments, as well as resource blocks of modules are not considered.
    
## Modules

No modules.

        ## Resources by Files

            ### main.tf

            | Name | Type |
            |------|------|
                  | [azapi_resource.eds](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
                  | [azuread_group.aaddc_admins](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group) | resource |
                  | [azuread_service_principal.eds](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
                  | [azurerm_network_security_rule.AllowPSRemoting](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
                  | [azurerm_network_security_rule.AllowRD](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
                  | [azurerm_network_security_rule.AzureActiveDirectoryDomainServices](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
                  | [azurerm_network_security_rule.AzureFrontDoorFirstParty](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
                  | [azurerm_network_security_rule.AzureMonitor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
                  | [azurerm_network_security_rule.AzureUpdateDelivery](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
                  | [azurerm_network_security_rule.GuestAndHybridManagement](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
                  | [azurerm_network_security_rule.MicrosoftEntraID](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
                  | [azurerm_network_security_rule.Storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
                  | [azurerm_network_security_rule.deny_all_outbound](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
    
<!-- END_TF_DOCS -->

## Contribute

Please use Pull requests to contribute.

When a new Feature or Fix is ready to be released, create a new Github release and adhere to [Semantic Versioning 2.0.0](https://semver.org/lang/de/spec/v2.0.0.html).