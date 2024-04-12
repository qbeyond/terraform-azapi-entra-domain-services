locals {
  ldaps_settings = !var.ldaps_settings.ldaps ? {
    ldaps = "Disabled"
    } : {
    externalAccess         = var.ldaps_settings.externalAccess ? "Enabled" : "Disabled"
    ldaps                  = "Enabled"
    pfxCertificate         = var.ldaps_settings.pfxCertificate
    pfxCertificatePassword = var.ldaps_settings.pfxCertificatePassword
  }
}
