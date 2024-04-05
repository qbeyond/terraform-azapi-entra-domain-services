output "domain_controller_ip_addresses" {
  value = azurerm_active_directory_domain_service.eds.initial_replica_set[0].domain_controller_ip_addresses
}
