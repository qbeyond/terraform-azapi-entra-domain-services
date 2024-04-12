terraform {
  required_providers {
    azapi = {
      source = "Azure/azapi"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.48.0"
    }
  }
}
