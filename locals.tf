# locals {
#   eds_vnet_str   = replace(var.eds_vnet_cidr, "/[./]/", "-")
#   eds_subnet_str = replace(var.eds_subnet_cidr, "/[./]/", "-")
# }

locals {
  ldaps_settings = !var.ldaps_settings.ldaps ? {} : {
    externalAccess         = var.ldaps_settings.externalAccess ? "Enabled" : "Disabled"
    ldaps                  = "Enabled"
    pfxCertificate         = var.ldaps_settings.pfxCertificate
    pfxCertificatePassword = var.ldaps_settings.pfxCertificatePassword
  }
}
