locals {
  ldaps_settings_disabled = {
    ldaps = false
  }
  ldaps_settings = var.ldaps_settings == null ? local.ldaps_settings_disabled : {
    externalAccess         = var.ldaps_settings.externalAccess ? "Enabled" : "Disabled"
    ldaps                  = "Enabled"
    pfxCertificate         = var.ldaps_settings.pfxCertificate
    pfxCertificatePassword = var.ldaps_settings.pfxCertificatePassword
  }
}
