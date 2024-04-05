resource "azurerm_resource_group" "eds" {
  name     = "rg-EntraDomainServices-dev-01"
  location = var.location
}

resource "azurerm_virtual_network" "eds" {
  name                = "vnet-${local.eds_vnet_str}-westeurope"
  location            = azurerm_resource_group.eds.location
  resource_group_name = azurerm_resource_group.eds.name
  address_space       = [var.eds_vnet_cidr]
}

resource "azurerm_subnet" "eds" {
  name                 = "snet-${local.eds_subnet_str}-EDS"
  resource_group_name  = azurerm_resource_group.eds.name
  virtual_network_name = azurerm_virtual_network.eds.name
  address_prefixes     = [var.eds_subnet_cidr]
}

resource "azurerm_network_security_group" "eds" {
  name                = "nsg-${local.eds_subnet_str}-Identity-EDS"
  location            = azurerm_resource_group.eds.location
  resource_group_name = azurerm_resource_group.eds.name

  # Commented out because @Christian doesn't know this rule and thinks we don't need it
  #   security_rule {
  #     name                       = "AllowSyncWithAzureAD"
  #     priority                   = 101
  #     direction                  = "Inbound"
  #     access                     = "Allow"
  #     protocol                   = "Tcp"
  #     source_port_range          = "*"
  #     destination_port_range     = "443"
  #     source_address_prefix      = "AzureActiveDirectoryDomainServices"
  #     destination_address_prefix = "*"
  #   }

  security_rule {
    name                       = "AllowRD"
    priority                   = 201
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "CorpNetSaw"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowPSRemoting"
    priority                   = 301
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5986"
    source_address_prefix      = "AzureActiveDirectoryDomainServices"
    destination_address_prefix = "*"
  }

  # Commented out because @Christian doesn't know this rule and thinks we don't need it
  #   security_rule {
  #     name                       = "AllowLDAPS"
  #     priority                   = 401
  #     direction                  = "Inbound"
  #     access                     = "Allow"
  #     protocol                   = "Tcp"
  #     source_port_range          = "*"
  #     destination_port_range     = "636"
  #     source_address_prefix      = "*"
  #     destination_address_prefix = "*"
  #   }
}

resource "azurerm_subnet_network_security_group_association" "eds" {
  subnet_id                 = azurerm_subnet.eds.id
  network_security_group_id = azurerm_network_security_group.eds.id
}

resource "azuread_group" "dc_admins" {
  display_name     = "AAD DC Administrators"
  security_enabled = true
}

resource "azuread_user" "admin" {
  user_principal_name = "fct_domainadmin@${var.domain}"
  display_name        = "DC Administrator"
  password            = var.domainadmin_password
}

resource "azuread_group_member" "admin" {
  group_object_id  = azuread_group.dc_admins.object_id
  member_object_id = azuread_user.admin.object_id
}

# TODO: There needs to be a service principal for domain services
# resource "azuread_service_principal" "eds" {
#   client_id = "2565bd9d-da50-47d4-8b85-4c97f669dc36" // published app for domain services
# }

resource "azurerm_active_directory_domain_service" "eds" {
  name                = var.domain
  location            = azurerm_resource_group.eds.location
  resource_group_name = azurerm_resource_group.eds.name

  domain_name               = var.domain
  sku                       = var.eds_sku
  filtered_sync_enabled     = true
  domain_configuration_type = "ResourceTrusting"

  initial_replica_set {
    subnet_id = azurerm_subnet.eds.id
  }

  notifications {
    additional_recipients = []
    notify_dc_admins      = true
    notify_global_admins  = true
  }

  security {
    sync_kerberos_passwords = true
    sync_ntlm_passwords     = true
    sync_on_prem_passwords  = true
  }

  tags = {
    Environment = var.environment
  }

  depends_on = [
    # azuread_service_principal.eds,
    azurerm_subnet_network_security_group_association.eds,
  ]
}
