output "mdc_arm_details" {
  value                 = azurerm_security_center_subscription_pricing.mdc_arm
  description           = "The MDFC ARM details."
}

output "mdc_servers_details" {
  value                 = azurerm_security_center_subscription_pricing.mdc_servers
  description           = "The MDFC Servers details."
}

output "mdc_app_services_details" {
  value                 = azurerm_security_center_subscription_pricing.mdc_app_service
  description           = "The MDFC App Services details."
}

output "mdc_key_vault_details" {
  value                 = azurerm_security_center_subscription_pricing.mdc_key_vault
  description           = "The MDFC Key Vault details."
}

output "mdc_storage_details" {
  value                 = azurerm_security_center_subscription_pricing.mdc_storage
  description           = "The MDFC Storage details."
}

output "mdc_sql_details" {
  value                 = azurerm_security_center_subscription_pricing.mdc_sql
  description           = "The MDFC SQL details."
}

output "mdc_sql_virtual_machine_details" {
  value                 = azurerm_security_center_subscription_pricing.mdc_sql_virtual_machine
  description           = "The MDFC SQL VM details."
}

output "mdc_aks_details" {
  value                 = azurerm_security_center_subscription_pricing.mdc_aks
  description           = "The MDFC AKS details."
}

output "mdc_container_registry_details" {
  value                 = azurerm_security_center_subscription_pricing.mdc_container_registry
  description           = "The MDFC Container Registry details."
}

output "mdc_containers_details" {
  value                 = azurerm_security_center_subscription_pricing.mdc_containers
  description           = "The MDFC Containers details."
}

output "mdc_dns_details" {
  value                 = azurerm_security_center_subscription_pricing.mdc_dns
  description           = "The MDFC DNS details."
}

output "mdc_osrdb_details" {
  value                 = azurerm_security_center_subscription_pricing.mdc_osrdb
  description           = "The MDFC OSRDB details."
}

output "mdc_contact_details" {
  value                 = azurerm_security_center_contact.mdc_contacts
  description           = "The MDFC contact details."
}
/*
output "mdc_auto_provisioning" {
  value                 = azurerm_security_center_auto_provisioning.auto_provisioning
  description           = "The MDFC auto provisioning details."
}
/*
output "mdc_log_analytics_export_details" {
  value                 = azurerm_security_center_automation.export_log_analytics
  description           = "The MDFC export to Log Analytics details."
}
/*
output "mdc_event_hub_export_details" {
  value                 = azurerm_security_center_automation.export_event_hub
  description           = "The MDFC export to Event Hub details."
}
*/