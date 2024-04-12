terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.49.0"
    }
    azapi = {
      source = "Azure/azapi"
    }
  }
}
provider "azurerm" {
  features {}

  skip_provider_registration = true
}

provider "azapi" {
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

# The following network security rules are required for entra domain services to work.
resource "azurerm_network_security_group" "deploy" {
  name                = "deploy-nsg"
  location            = azurerm_resource_group.deploy.location
  resource_group_name = azurerm_resource_group.deploy.name
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

  # Note: domain must either be the tenant's domain or a custom domain registered and verified in EID
  domain               = "example.onmicrosoft.com"
  aaddc_admin_password = "S3curePassword!"
  subnet               = azurerm_subnet.deploy
  notification_settings = {
    additionalRecipients = ["example1@example.de", "example2@example.de"]
    notifyAADDCAdmins    = true
    notifyGlobalAdmins   = false
  }
  ldaps_settings = {
    ldaps = false
  }
  security_settings = {
    channelBinding        = optional(bool, false)
    kerberosArmoring      = optional(bool, false)
    kerberosRc4Encryption = optional(bool, true)
  }
  location          = "West Europe"
  resource_group_id = azurerm_resource_group.aadds.id
}