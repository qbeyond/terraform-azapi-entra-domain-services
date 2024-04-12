terraform {
  required_providers {
    azapi = {
      source = "Azure/azapi"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.48.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.49.0"
    }
  }
}
