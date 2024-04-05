locals {
  eds_vnet_str   = replace(var.eds_vnet_cidr, "/[./]/", "-")
  eds_subnet_str = replace(var.eds_subnet_cidr, "/[./]/", "-")
}