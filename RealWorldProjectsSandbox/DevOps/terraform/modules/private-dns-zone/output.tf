output "zone_ids" {
  description = "The app service plan info for downstream"
  value = {
    psql     = var.provision_psql_zone ? azurerm_private_dns_zone.private_psql_zone[0].id : null
    internal = var.provision_internal_zone ? azurerm_private_dns_zone.internal[0].id : null
  }
}
