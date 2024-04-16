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

check "nsg_association" {
  data "azurerm_subnet" "eds" {
    name                 = split("/", var.subnet.id)[10]
    virtual_network_name = split("/", var.subnet.id)[8]
    resource_group_name  = split("/", var.subnet.id)[4]
  }

  assert {
    condition     = data.azurerm_subnet.eds.network_security_group_id == var.network_security_group.id
    error_message = "The provided subnet is not associated with the provided network security group."
  }
}

// Inbound NSG rules for Microsoft Support access. Without it EDS does not work.
resource "azurerm_network_security_rule" "AllowRD" {
  name                        = "AllowRD"
  priority                    = 201
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "CorpNetSaw"
  destination_address_prefix  = "*"
  resource_group_name         = var.network_security_group.resource_group_name
  network_security_group_name = var.network_security_group.name
}

resource "azurerm_network_security_rule" "AllowPSRemoting" {
  name                        = "AllowPSRemoting"
  priority                    = 301
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "5986"
  source_address_prefix       = "AzureActiveDirectoryDomainServices"
  destination_address_prefix  = "*"
  resource_group_name         = var.network_security_group.resource_group_name
  network_security_group_name = var.network_security_group.name
}

// Outbound rules NSG for Microsoft Support access. Without it EDS does not work.
resource "azurerm_network_security_rule" "AzureActiveDirectoryDomainServices" {
  name                        = "Allow_Subnet_to_AzureActiveDirectoryDomainServices_HTTPS_Outbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "AzureActiveDirectoryDomainServices"
  resource_group_name         = var.network_security_group.resource_group_name
  network_security_group_name = var.network_security_group.name
}

resource "azurerm_network_security_rule" "AzureMonitor" {
  name                        = "Allow_Subnet_to_AzureMonitor_HTTPS_Outbound"
  priority                    = 110
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "AzureMonitor"
  resource_group_name         = var.network_security_group.resource_group_name
  network_security_group_name = var.network_security_group.name
}

resource "azurerm_network_security_rule" "Storage" {
  name                        = "Allow_Subnet_to_Storage_HTTPS_Outbound"
  priority                    = 120
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "Storage"
  resource_group_name         = var.network_security_group.resource_group_name
  network_security_group_name = var.network_security_group.name
}

resource "azurerm_network_security_rule" "MicrosoftEntraID" {
  name                        = "Allow_Subnet_to_MicrosoftEntraID_HTTPS_Outbound"
  priority                    = 130
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "AzureActiveDirectory"
  resource_group_name         = var.network_security_group.resource_group_name
  network_security_group_name = var.network_security_group.name
}

resource "azurerm_network_security_rule" "AzureUpdateDelivery" {
  name                        = "Allow_Subnet_to_AzureUpdateDelivery_HTTPS_Outbound"
  priority                    = 140
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "AzureUpdateDelivery"
  resource_group_name         = var.network_security_group.resource_group_name
  network_security_group_name = var.network_security_group.name
}

resource "azurerm_network_security_rule" "AzureFrontDoorFirstParty" {
  name                        = "Allow_Subnet_to_AzureFrontDoorFirstParty_HTTPS_Outbound"
  priority                    = 150
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "AzureFrontDoor.FirstParty"
  resource_group_name         = var.network_security_group.resource_group_name
  network_security_group_name = var.network_security_group.name
}

resource "azurerm_network_security_rule" "GuestAndHybridManagement" {
  name                        = "Allow_Subnet_to_GuestAndHybridManagement_HTTPS_Outbound"
  priority                    = 160
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "GuestAndHybridManagement"
  resource_group_name         = var.network_security_group.resource_group_name
  network_security_group_name = var.network_security_group.name
}

resource "azurerm_network_security_rule" "deny_all_outbound" {
  name                        = "Deny_all_Outbound"
  priority                    = 1000
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.network_security_group.resource_group_name
  network_security_group_name = var.network_security_group.name
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
  timeouts {
    create = "60m"
    delete = "60m"
  }
}


check "edc_security_configuration" {
  assert {
    condition     = var.security_settings.channelBinding == true
    error_message = "LDAP signing should be enabled."
  }
  assert {
    condition     = var.security_settings.kerberosArmoring == true
    error_message = "Kerberos armoring should be enabled."
  }
  assert {
    condition     = var.security_settings.kerberosRc4Encryption == false
    error_message = "Kerberos RC4 encryption is old and should be disabled for EDS."
  }
  assert {
    condition     = var.security_settings.ldapSigning == true
    error_message = "LDAP signing should be enabled."
  }
  assert {
    condition     = var.security_settings.ntlmV1 == false
    error_message = "NTLMv1 is old and should be disabled."
  }
  assert {
    condition     = var.security_settings.tlsV1 == false
    error_message = "TLSv1 is old and should be disabled."
  }
  assert {
    condition     = local.ldaps_settings.ldaps == "enabled"
    error_message = "LDAPS should be enabled."
  }
}
