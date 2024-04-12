terraform {
  required_version = ">=1.5.0"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = ">= 1.0.0"
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
