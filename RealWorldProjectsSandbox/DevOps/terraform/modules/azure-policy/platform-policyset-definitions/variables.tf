# variable "platform_management_group_id" {
#   type              = string
#   description       = "The UUID of the Platform Management Group to assign the policy initiative."
# }

variable "tag_1" {
  type              = string
  description       = "The first mandatory tag key."
  default           = "domain"
}

variable "tag_2" {
  type              = string
  description       = "The second mandatory tag key."
  default           = "provisioner"
}

variable "tag_3" {
  type              = string
  description       = "The third mandatory tag key."
  default           = "location"
}

variable "tag_4" {
  type              = string
  description       = "The fourth mandatory tag key."
  default           = "product"
}

variable "tag_5" {
  type              = string
  description       = "The fourth mandatory tag key."
  default           = "team"
}

variable "cognitive_services_effect" {
  type                  = string
  description           = "The Public network access should be disabled for Cognitive Services accounts policy effect - Audit, Deny or Disabled."
  default               = "Deny"
}

locals { // locals for 'cognitive_services_effect' allowed values
  cognitive_services_effect_allowed_values  = [
    "Audit",
    "Deny",
    "Disabled"
  ]
  // will fail if [cognitive_services_effect] is invalid:
  validate_cognitive_services_effect_allowed_value = index(local.cognitive_services_effect_allowed_values, var.cognitive_services_effect)
}

# variable "nic_pub_ips_effect" {
#   type                  = string
#   description           = "VM NIC's should not have public IP address - Deny."
#   default               = "Deny"
# }

# locals { // locals for 'nic_pub_ips_effect' allowed values
#   nic_pub_ips_effect_allowed_values  = [
#     "Deny"
#   ]
#   // will fail if [nic_pub_ips_effect] is invalid:
#   validate_nic_pub_ips_effect_allowed_value = index(local.nic_pub_ips_effect_allowed_values, var.nic_pub_ips_effect)
# }

variable "sql_effect" {
  type                  = string
  description           = "Public network access on Azure SQL Database should be disabled policy effect - Audit, Deny or Disabled."
  default               = "Deny"
}

locals { // locals for 'sql_effect' allowed values
  sql_effect_allowed_values  = [
    "Audit",
    "Deny",
    "Disabled"
  ]
  // will fail if [sql_effect] is invalid:
  validate_sql_effect_allowed_value = index(local.sql_effect_allowed_values, var.sql_effect)
}

variable "postgressql_effect" {
  type                  = string
  description           = "Public network access should be disabled for PostgreSQL servers policy effect - Audit, Deny or Disabled."
  default               = "Deny"
}

locals { // locals for 'postgressql_effect' allowed values
  postgressql_effect_allowed_values  = [
    "Audit",
    "Deny",
    "Disabled"
  ]
  // will fail if [postgressql_effect] is invalid:
  validate_postgressql_effect_allowed_value = index(local.postgressql_effect_allowed_values, var.postgressql_effect)
}

variable "mysql_effect" {
  type                  = string
  description           = "Public network access should be disabled for MySQL servers policy effect - Audit, Deny or Disabled."
  default               = "Deny"
}

locals { // locals for 'mysql_effect' allowed values
  mysql_effect_allowed_values  = [
    "Audit",
    "Deny",
    "Disabled"
  ]
  // will fail if [mysql_effect] is invalid:
  validate_mysql_effect_allowed_value = index(local.mysql_effect_allowed_values, var.mysql_effect)
}

variable "mariadb_effect" {
  type                  = string
  description           = "Public network access should be disabled for MariaDB servers policy effect - Audit, Deny or Disabled."
  default               = "Deny"
}

locals { // locals for 'mariadb_effect' allowed values
  mariadb_effect_allowed_values  = [
    "Audit",
    "Deny",
    "Disabled"
  ]
  // will fail if [mariadb_effect] is invalid:
  validate_mariadb_effect_allowed_value = index(local.mariadb_effect_allowed_values, var.mariadb_effect)
}

variable "cosmosdb_effect" {
  type                  = string
  description           = "Azure Cosmos DB should disable public network access policy effect - Audit, Deny or Disabled."
  default               = "Deny"
}

locals { // locals for 'cosmosdb_effect' allowed values
  cosmosdb_effect_allowed_values  = [
    "Audit",
    "Deny",
    "Disabled"
  ]
  // will fail if [cosmosdb_effect] is invalid:
  validate_cosmosdb_effect_allowed_value = index(local.cosmosdb_effect_allowed_values, var.cosmosdb_effect)
}

variable "sqlmi_aad_effect" {
  type                  = string
  description           = "Azure SQL Managed Instance should have Azure Active Directory Only Authentication enabled policy effect - Audit, Deny or Disabled."
  default               = "Audit"    
}
locals { // locals for 'sqlmi_aad_effect' allowed values
  sqlmi_aad_effect_allowed_values  = [
    "Audit",
    "Deny",
    "Disabled"
  ]
  // will fail if [sqlmi_aad_effect] is invalid:
  validate_sqlmi_aad_effect_allowed_value = index(local.sqlmi_aad_effect_allowed_values, var.sqlmi_aad_effect)
}

variable "sqlmi_pub_effect" {
  type                  = string
  description           = "Azure SQL Managed Instances should disable public network access policy effect - Audit, Deny or Disabled."
  default               = "Deny"    
}
locals { // locals for 'sqlmi_pub_effect' allowed values
  sqlmi_pub_effect_allowed_values  = [
    "Audit",
    "Deny",
    "Disabled"
  ]
  // will fail if [sqlmi_pub_effect] is invalid:
  validate_sqlmi_pub_effect_allowed_value = index(local.sqlmi_pub_effect_allowed_values, var.sqlmi_pub_effect)
}

variable "sql_private_endpoint_effect" {
  type                  = string
  description           = "Private endpoint connections on Azure SQL Database should be enabled - Audit or Disabled."
  default               = "Audit"
}

locals { // locals for 'sql_private_endpoint_effect' allowed values
  sql_private_endpoint_effect_allowed_values  = [
    "Audit",
    "Disabled"
  ]
  // will fail if [sql_private_endpoint_effect] is invalid:
  validate_sql_private_endpoint_effect_allowed_value = index(local.sql_private_endpoint_effect_allowed_values, var.sql_private_endpoint_effect)
}

variable "key_vault_public_network_effect" {
  type                  = string
  description           = "Azure Key Vault should disable public network access - Audit, Deny or Disabled."
  default               = "Deny"
}

locals { // locals for 'key_vault_public_network_effect' allowed values
  key_vault_public_network_effect_allowed_values  = [
    "Audit",
    "Deny",
    "Disabled"
  ]
  // will fail if [key_vault_public_network_effect] is invalid:
  validate_key_vault_public_network_effect_allowed_value = index(local.key_vault_public_network_effect_allowed_values, var.key_vault_public_network_effect)
}

variable "key_vault_private_link_effect" {
  type                  = string
  description           = "[Preview]: Azure Key Vaults should use private link - Audit, Deny or Disabled."
  default               = "Deny"
}

locals { // locals for 'key_vault_private_link_effect' allowed values
  key_vault_private_link_effect_allowed_values  = [
    "Audit",
    "Deny",
    "Disabled"
  ]
  // will fail if [key_vault_private_link_effect] is invalid:
  validate_key_vault_private_link_effect_allowed_value = index(local.key_vault_private_link_effect_allowed_values, var.key_vault_private_link_effect)
}

variable "storage_public_network_effect" {
  type                  = string
  description           = "Storage accounts should disable public network access - Audit, Deny or Disabled."
  default               = "Audit"
}

locals { // locals for 'storage_public_network_effectt' allowed values
  storage_public_network_effect_allowed_values  = [
    "Audit",
    "Deny",
    "Disabled"
  ]
  // will fail if [storage_public_network_effectt] is invalid:
  validate_storage_public_network_effect_allowed_value = index(local.storage_public_network_effect_allowed_values, var.storage_public_network_effect)
}

variable "log_analytics_ingestion_effect" {
  type                  = string
  description           = "Log Analytics workspaces should block log ingestion and querying from public networks - Audit, Deny or Disabled."
  default               = "Audit"
}

locals { // locals for 'log_analytics_ingestion_effect' allowed values
  log_analytics_ingestion_effect_allowed_values  = [
    "Audit",
    "Deny",
    "Disabled"
  ]
  // will fail if [log_analytics_ingestion_effect] is invalid:
  validate_log_analytics_ingestion_effect_allowed_value = index(local.log_analytics_ingestion_effect_allowed_values, var.log_analytics_ingestion_effect)
}

variable "app_insights_ingestion_effect" {
  type                  = string
  description           = "Application Insights components should block log ingestion and querying from public networks - Audit, Deny or Disabled."
  default               = "Audit"
}

locals { // locals for 'app_insights_ingestion_effect' allowed values
  app_insights_ingestion_effect_allowed_values  = [
    "Audit",
    "Deny",
    "Disabled"
  ]
  // will fail if [app_insights_ingestion_effect] is invalid:
  validate_app_insights_ingestion_effect_allowed_value = index(local.app_insights_ingestion_effect_allowed_values, var.app_insights_ingestion_effect)
}

variable "app_services_vnet_effect" {
  type                  = string
  description           = "App Service apps should be injected into a virtual network - Audit, Deny or Disabled."
  default               = "Deny"
}

locals { // locals for 'app_services_vnet_effect' allowed values
  app_services_vnet_effect_allowed_values  = [
    "Audit",
    "Deny",
    "Disabled"
  ]
  // will fail if [app_services_vnet_effect] is invalid:
  validate_app_services_vnet_effect_allowed_value = index(local.app_services_vnet_effect_allowed_values, var.app_services_vnet_effect)
}

variable "app_services_private_link_effect" {
  type                  = string
  description           = "App Service apps should use private link - Audit, Deny or Disabled."
  default               = "AuditIfNotExists"
}

locals { // locals for 'app_services_private_link_effect' allowed values
  app_services_private_link_effect_allowed_values  = [
    "AuditIfNotExists",
    "Disabled"
  ]
  // will fail if [app_services_private_link_effect] is invalid:
  validate_app_services_private_link_effect_allowed_value = index(local.app_services_private_link_effect_allowed_values, var.app_services_private_link_effect)
}

variable "apim_vnet_effect" {
  type                  = string
  description           = "API Management services should use a virtual network - Audit or Disabled."
  default               = "Audit"
}

locals { // locals for 'apim_vnet_effect' allowed values
  apim_vnet_effect_allowed_values  = [
    "Audit",
    "Disabled"
  ]
  // will fail if [apim_vnet_effect] is invalid:
  validate_apim_vnet_effect_allowed_value = index(local.apim_vnet_effect_allowed_values, var.apim_vnet_effect)
}

variable "app_config_public_network_effect" {
  type                  = string
  description           = "App Configuration should disable public network access - Audit, Deny or Disabled."
  default               = "Deny"
}

locals { // locals for 'app_config_public_network_effect' allowed values
  app_config_public_network_effect_allowed_values  = [
    "Audit",
    "Deny",
    "Disabled"
  ]
  // will fail if [app_config_public_network_effect] is invalid:
  validate_app_config_public_network_effect_allowed_value = index(local.app_config_public_network_effect_allowed_values, var.app_config_public_network_effect)
}

variable "acr_loc_adm_effect" {
  type                  = string
  description           = "Container registries should have local admin account disabled policy effect - Audit, Deny, Disabled"
  default               = "Audit"
}

locals { // locals for 'acr_loc_adm_effect' allowed values
  acr_loc_adm_effect_allowed_values  = [
    "Audit",
    "Deny",
    "Disabled"
  ]
  // will fail if [acr_loc_adm_effect] is invalid:
  validate_acr_loc_adm_effect_allowed_value = index(local.acr_loc_adm_effect_allowed_values, var.acr_loc_adm_effect)
}

variable "service_bus_private_link_effect" {
  type                  = string
  description           = "Azure Service Bus namespaces should use private link - AuditIfNotExists, or Disabled."
  default               = "AuditIfNotExists"
}

locals { // locals for 'service_bus_private_link_effect' allowed values
  service_bus_private_link_effect_allowed_values  = [
    "AuditIfNotExists",
    "Disabled"
  ]
  // will fail if [service_bus_private_link_effect] is invalid:
  validate_service_bus_private_link_effect_allowed_value = index(local.service_bus_private_link_effect_allowed_values, var.service_bus_private_link_effect)
}

variable "service_bus_public_network_effect" {
  type                  = string
  description           = "Service Bus Namespaces should disable public network access - Audit, Deny or Disabled."
  default               = "Deny"
}

locals { // locals for 'service_bus_public_network_effect' allowed values
  service_bus_public_network_effect_allowed_values  = [
    "Audit",
    "Deny",
    "Disabled"
  ]
  // will fail if [service_bus_public_network_effect] is invalid:
  validate_service_bus_public_network_effect_allowed_value = index(local.service_bus_public_network_effect_allowed_values, var.service_bus_public_network_effect)
}

variable "apim_public_network_effect" {
  type                  = string
  description           = "API Management services should disable public network access - AuditIfNotExists or Disabled."
  default               = "AuditIfNotExists"
}

variable "global_management_group_id" {
  type              = string
  description       = "The UUID of the Management Group to assign the policy initiative."
}

locals { // locals for 'apim_public_network_effect' allowed values
  apim_public_network_effect_allowed_values  = [
    "AuditIfNotExists",
    "Disabled"
  ]
  // will fail if [apim_public_network_effect] is invalid:
  validate_apim_public_network_effect_allowed_value = index(local.apim_public_network_effect_allowed_values, var.apim_public_network_effect)
}