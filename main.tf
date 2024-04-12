resource "azuread_group" "aaddc_admins" {
  display_name     = "AAD DC Administrators"
  security_enabled = true
}

resource "azuread_user" "aaddc_admin" {
  user_principal_name = "fct_black_eds@${var.domain}"
  display_name        = "Function EDS Admin"
  given_name          = "Function"
  surname             = "EDS Admin"
  job_title           = "Administrator of Entra Domain Services"
  password            = var.aaddc_admin_password
}

resource "azuread_group_member" "admin" {
  group_object_id  = azuread_group.aaddc_admins.object_id
  member_object_id = azuread_user.aaddc_admin.object_id
}

resource "azuread_service_principal" "eds" {
  client_id = "2565bd9d-da50-47d4-8b85-4c97f669dc36" // published app for domain services
}

resource "azapi_resource" "eds" {
  type      = "Microsoft.AAD/domainServices@2022-12-01"
  name      = var.domain
  location  = var.location
  parent_id = var.resource_group_id
  tags      = var.tags
  body = jsonencode({
    properties = {
      domainConfigurationType = var.domain_configuration_type
      domainName              = var.domain
      domainSecuritySettings = {
        channelBinding        = var.security_settings.channelBinding ? "Enabled" : "Disabled"
        kerberosArmoring      = var.security_settings.kerberosArmoring ? "Enabled" : "Disabled"
        kerberosRc4Encryption = var.security_settings.kerberosRc4Encryption ? "Enabled" : "Disabled"
        ldapSigning           = var.security_settings.ldapSigning ? "Enabled" : "Disabled"
        ntlmV1                = var.security_settings.ntlmV1 ? "Enabled" : "Disabled"
        syncKerberosPasswords = var.security_settings.syncKerberosPasswords ? "Enabled" : "Disabled"
        syncNtlmPasswords     = var.security_settings.syncNtlmPasswords ? "Enabled" : "Disabled"
        syncOnPremPasswords   = var.security_settings.syncOnPremPasswords ? "Enabled" : "Disabled"
        tlsV1                 = var.security_settings.tlsV1 ? "Enabled" : "Disabled"
      }
      filteredSync  = var.filtered_sync ? "Enabled" : "Disabled"
      ldapsSettings = local.ldaps_settings
      notificationSettings = {
        additionalRecipients = var.notification_settings.additionalRecipients
        notifyDcAdmins       = var.notification_settings.notifyAADDCAdmins ? "Enabled" : "Disabled"
        notifyGlobalAdmins   = var.notification_settings.notifyGlobalAdmins ? "Enabled" : "Disabled"
      }
      replicaSets = [
        {
          location = var.location
          subnetId = var.subnet.id
        }
      ]
      sku       = var.sku
      syncScope = var.sync_scope
    }
  })
}
