variable "eds_vnet_cidr" {
  type        = string
  description = "The address space for the virtual network for EDS"

  default = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.eds_vnet_cidr, 32))
    error_message = "Must be valid IPv4 CIDR."
  }
}

variable "eds_subnet_cidr" {
  type        = string
  description = "The address space for the subnet where the EDS domain controllers will reside"

  default = "10.0.1.0/24"

  validation {
    condition     = can(cidrhost(var.eds_subnet_cidr, 32))
    error_message = "Must be valid IPv4 CIDR."
  }
}

variable "location" {
  type        = string
  description = "The location for the resource groups and resources"

  default = "westeurope"
}

variable "domain" {
  type        = string
  description = "The domain name for the Entra Domain Services"
}

variable "eds_sku" {
  type        = string
  description = "The SKU for the Entra Domain Services (Standard/Enterprise/Premium)"

  default = "Enterprise"
}

variable "environment" {
  type        = string
  description = "The development stage (dev/test/prod)"

  default = "dev"
}

variable "domainadmin_password" {
  type        = string
  sensitive   = true
  description = "The password assigned to the domain admin fct_domainadmin@domain"
}
