variable "subnet" {
  type = object({
    id               = string
    address_prefixes = list(string)
  })
  nullable    = false
  description = "The variable takes the subnet as input and takes the id and the address prefix for further configuration."
}

variable "resource_group_id" {
  type        = string
  nullable    = false
  description = "Id of the resource group where the resources will be created."
}

variable "tags" {
  type        = map(string)
  default     = {}
  nullable    = false
  description = "A map of tags that will be set on every resource this module creates."
}

variable "domain_configuration_type" {
  type        = string
  default     = "FullySynced"
  nullable    = false
  description = "The configuration type of this Active Directory Domain."
  validation {
    condition     = contains(["FullySynced", "ResourceTrusting"], var.domain_configuration_type)
    error_message = "Possible values for the configuration type are FullySynced and ResourceTrusting."
  }
}

variable "security_settings" {
  type = object({
    channelBinding        = optional(bool, true)
    kerberosArmoring      = optional(bool, true)
    kerberosRc4Encryption = optional(bool, false)
    ldapSigning           = optional(bool, true)
    ntlmV1                = optional(bool, false)
    syncKerberosPasswords = optional(bool, true)
    syncNtlmPasswords     = optional(bool, true)
    syncOnPremPasswords   = optional(bool, true)
    tlsV1                 = optional(bool, false)
  })
  default     = {}
  description = <<-DOC
  ```
    channelBinding: Require all LDAP clients to provide channel binding information when communicating with the directory. Any client that does not provide this information will fail.
    kerberosArmoring: Enable or disable Kerberos Armoring for your managed domain. This will provide a protected channel between the Kerberos client and the KDC.
    kerberosRc4Encryption: Enable or disable Kerberos RC4 encryption for your managed domain. When Kerberos RC4 encryption is disabled, all Kerberos requests that use RC4 encryption will fail.
    ldapSigning: Require all LDAP clients to request signing during bind time. Any bind request that does not request signing will fail.
    ntlmV1: Enable or disable NTLM v1 authentication for your managed domain. When NTLM v1 authentication is disabled, all NTLM v1 authentication requests will fail.
    syncKerberosPasswords: Enable or disable Kerberos password hash synchronization. When this is disabled, synchronized user accounts will be unable to use Kerberos authentication in the managed domain.
    syncNtlmPasswords: Enable or disable NTLM password hash synchronization. When this is disabled, synchronized user accounts will be unable to use NTLM authentication in the managed domain.
    syncOnPremPasswords: Enable or disable password hash synchronization for on-premises accounts. When this is disabled, on-premises user accounts will be unable to authenticate in the managed domain. Cloud-only users will be unaffected.
    tlsV1: Enable or disable TLS 1 legacy mode for your managed domain.
  ```
  DOC
}

variable "filtered_sync" {
  type        = bool
  default     = true
  description = "Enabled or Disabled flag to turn on Group-based filtered sync"
}

variable "ldaps_settings" {
  type = object({
    externalAccess         = optional(bool, false)
    ldaps                  = bool
    pfxCertificate         = optional(string, "")
    pfxCertificatePassword = optional(string, "")
  })
  description = <<-DOC
  ```
    externalAccess: A flag to determine whether or not Secure LDAP access over the internet is enabled or disabled.	
    ldaps: A flag to determine whether or not Secure LDAP is enabled or disabled.
    pfxCertificate: The certificate required to configure Secure LDAP. The parameter passed here should be a base64encoded representation of the certificate pfx file.
    pfxCertificatePassword: The password to decrypt the provided Secure LDAP certificate pfx file.
  ```
  DOC
}

variable "notification_settings" {
  type = object({
    additionalRecipients = optional(list(string), [])
    notifyDcAdmins       = optional(bool, true)
    notifyGlobalAdmins   = optional(bool, true)
  })
  description = "Choose who should get email alerts for issues affecting this managed domain."
}

# variable "resource_forest_settings" {
#   type = object({
#     resourceForest = optional(string, "")
#     settings = list(object({
#       friendlyName      = string
#       remoteDnsIps      = string
#       trustDirection    = string
#       trustedDomainFqdn = string
#       trustPassword     = string
#     }))
#   })
#   # TODO: Not the best description ...
#   description = "A list of settings for Resource Forest"
# }

variable "location" {
  type        = string
  description = "The location for the resource groups and resources"
}

variable "domain" {
  type        = string
  description = "The domain name for the Entra Domain Services"
}

variable "sku" {
  type        = string
  description = "The SKU for the Entra Domain Services (Standard/Enterprise/Premium)"

  default = "Enterprise"

  validation {
    condition     = contains(["Standard", "Enterprise", "Premium"], var.sku)
    error_message = "Possible values for the sku are Standard, Enterprise and Premium."
  }
}

variable "sync_scope" {
  type        = string
  description = "All users in AAD are synced to AAD DS domain or only users actively syncing in the cloud"

  default = "CloudOnly"

  validation {
    condition     = contains(["All", "CloudOnly"], var.sync_scope)
    error_message = "Possible values for the sync scope are All and CloudOnly."
  }
}

variable "aaddc_admin_password" {
  type        = string
  sensitive   = true
  description = "The password assigned to the domain admin fct_aadc_admin@domain"
}
