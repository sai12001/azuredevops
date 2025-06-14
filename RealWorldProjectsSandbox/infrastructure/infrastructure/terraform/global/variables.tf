variable "product" {
  description = "Which product this deploy is targeting for. Injected by environment settings"
  type        = string
  default     = "ng"
}
variable "environment" {
  description = "Which environment we are deploying, supporting dev, stg, pef, prd. This value will be auto injected by terragrunt"
  type        = string
}
variable "location" {
  description = "Deployment location for cluster, support Australia East, Australia Southeast etc"
  type        = string
  default     = "australiaeast"
}
variable "location_abbr" {
  description = "Deployment location for cluster, support Australia East, Australia Southeast etc"
  type        = string
  default     = "eau"
}

variable "domain_name" {
  description = "The domain name for infra component"
  type        = string
  default     = "infra"
}
variable "team_name" {
  description = "The team name for infra component"
  type        = string
  default     = "cloudops"
}

variable "wan_name" {
  description = "The name for virtual wan"
  type        = string
}

variable "firewall_name" {
  description = "The name for virtual hub firewall"
  type        = string
}
variable "firewall_sku_tier" {
  description = "SKU tier of the Firewall. Possible values are `Premium` and `Standard`."
  type        = string
}

variable "firewall_availibility_zones" {
  description = "Availability zones in which the Azure Firewall should be created."
  type        = list(number)
}

variable "firewall_dns_servers" {
  description = "List of DNS servers that the Azure Firewall will direct DNS traffic to for the name resolution"
  type        = list(string)
  default     = null
}

variable "firewall_private_ip_ranges" {
  description = "List of SNAT private CIDR IP ranges, or the special string `IANAPrivateRanges`, which indicates Azure Firewall does not SNAT when the destination IP address is a private range per IANA RFC 1918"
  type        = list(string)
  default     = null
}

variable "firewall_policy_id" {
  description = "ID of the Firewall Policy applied to this Firewall."
  type        = string
  default     = null
}

variable "firewall_private_ip" {
  description = "The Private IP Address of the Azure Firewall"
  type        = string
  default     = null
}

variable "firewall_public_ip" {
  description = "The Public IP Address of the Azure Firewall"
  type        = list(string)
  default     = null
}

#Place holder for Firewall Application Rules
# variable "firewall_application_rules" {
#   description = "List of application rules to apply to firewall."
#   type        = object({ 
#     collection_priority = string
#     action = string
#     rule = list(object({
#        name = string, 
#        source_addresses = list(string), 
#        destination_fqdns = list(string), 
#      }))
#       protocols = list(object({ 
#           type = string
#           port = string 
#       }))  
#   })
# }

variable "firewall_network_rules" {
  description = "List of network rules to apply to firewall."
  type = object({
    collection_priority = string
    action              = string
    rule = list(object({
      name                  = string,
      source_addresses      = list(string),
      destination_ports     = list(string),
      destination_addresses = list(string),
      protocols             = list(string)
    }))
  })
}

variable "firewall_nat_rules" {
  description = "List of NAT rules to apply to firewall."
  type = object({
    collection_priority = string
    action              = string
    rule = list(object({
      name                  = string,
      source_addresses      = list(string),
      destination_ports     = list(string),
      destination_addresses = list(string),
      protocols             = list(string),
      translated_address    = string,
      translated_port       = string
    }))
  })
}

variable "wan_hubs" {
  description = "The hubs in virtual wan"
  type = map(object({
    address_prefix = string
  }))
}

variable "default_route_table_id" {
  description = "Default Route Table ID"
  type        = string
}

variable "hub_connections" {
  type = map(object({
    hub_name = string
    vnet_id  = string
  }))
}
variable "hub_route_tables" {
  type = map(object({
    hub_name = string
    labels   = list(string)
    route = object({
      name              = string
      destinations_type = string
      destinations      = list(string)
      next_hop_type     = string
      connection_name   = string
    })
  }))
  default = {}
}

variable "core_vnet" {
  description = "Core vnet configuration"
  type = object({
    name          = string
    address_space = list(string)
    subnets = list(object({
      name     = string
      prefixes = list(string)
      delegation = optional(object({
        name = string
        service_delegation = object({
          name    = string
          actions = list(string)
        })
      }))
      service_endpoints = optional(list(string))
    }))
  })
}

variable "utils_vnet" {
  description = "Utils vnet configuration"
  type = object({
    name          = string
    address_space = list(string)
    subnets = list(object({
      name     = string
      prefixes = list(string)
      delegation = optional(object({
        name = string
        service_delegation = object({
          name    = string
          actions = list(string)
        })
      }))
      service_endpoints = optional(list(string))
    }))
  })
}


variable "agents_vmss_configs" {
  description = "VMSS configuration"
  type = object({
    name                 = string
    computer_name_prefix = string
    sku                  = optional(string)
    instances            = optional(number)
    admin_username       = optional(string)
    image = optional(object({
      publisher = optional(string)
      offer     = optional(string)
      sku       = optional(string)
      version   = optional(string)
    }))
    os_disk = optional(object({
      storage_account_type = optional(string)
      caching              = optional(string)
    }))
  })
}
variable "agents_vmss_configs_from_image" {
  description = "VMSS configuration"
  type = object({
    name                 = string
    computer_name_prefix = string
    sku                  = optional(string)
    instances            = optional(number)
    admin_username       = optional(string)
    image_id             = optional(string)
    os_disk = optional(object({
      storage_account_type = optional(string)
      caching              = optional(string)
    }))
  })
}

variable "dnsresolver_name" {
  description = "Name of the DNS private resolver"
  type        = string
}

variable "policy_initiative_name" {
  type        = string
  description = "The name of the policy initiative to assign, this is NOT the display name."
}

variable "global_management_group_id" {
  type        = string
  description = "The UUID of the Management Group to assign the policy initiative."
}

# variable "management_group_name" {
#   type              = string
#   description       = "The UUID of the Management Group to assign the policy initiative."
# }

variable "tag_1" {
  type        = string
  description = "The first mandatory tag key."
  default     = "provisioner"
}

variable "tag_2" {
  type        = string
  description = "The second mandatory tag key."
  default     = "provisioner"
}

variable "tag_3" {
  type        = string
  description = "The third mandatory tag key."
  default     = "location"
}

variable "tag_4" {
  type        = string
  description = "The fourth mandatory tag key."
  default     = "product"
}

variable "tag_5" {
  type        = string
  description = "The fourth mandatory tag key."
  default     = "team"
}

variable "cognitive_services_effect" {
  type        = string
  description = "The Public network access should be disabled for Cognitive Services accounts policy effect - Audit, Deny or Disabled."
  default     = "Deny"
}

locals { // locals for 'cognitive_services_effect' allowed values
  cognitive_services_effect_allowed_values = [
    "Audit",
    "Deny",
    "Disabled"
  ]
  // will fail if [cognitive_services_effect] is invalid:
  validate_cognitive_services_effect_allowed_value = index(local.cognitive_services_effect_allowed_values, var.cognitive_services_effect)
}

variable "sql_effect" {
  type        = string
  description = "Public network access on Azure SQL Database should be disabled policy effect - Audit, Deny or Disabled."
  default     = "Deny"
}

locals { // locals for 'sql_effect' allowed values
  sql_effect_allowed_values = [
    "Audit",
    "Deny",
    "Disabled"
  ]
  // will fail if [sql_effect] is invalid:
  validate_sql_effect_allowed_value = index(local.sql_effect_allowed_values, var.sql_effect)
}

variable "postgressql_effect" {
  type        = string
  description = "Public network access should be disabled for PostgreSQL servers policy effect - Audit, Deny or Disabled."
  default     = "Deny"
}

locals { // locals for 'postgressql_effect' allowed values
  postgressql_effect_allowed_values = [
    "Audit",
    "Deny",
    "Disabled"
  ]
  // will fail if [postgressql_effect] is invalid:
  validate_postgressql_effect_allowed_value = index(local.postgressql_effect_allowed_values, var.postgressql_effect)
}

variable "mysql_effect" {
  type        = string
  description = "Public network access should be disabled for MySQL servers policy effect - Audit, Deny or Disabled."
  default     = "Deny"
}

locals { // locals for 'mysql_effect' allowed values
  mysql_effect_allowed_values = [
    "Audit",
    "Deny",
    "Disabled"
  ]
  // will fail if [mysql_effect] is invalid:
  validate_mysql_effect_allowed_value = index(local.mysql_effect_allowed_values, var.mysql_effect)
}

variable "mariadb_effect" {
  type        = string
  description = "Public network access should be disabled for MariaDB servers policy effect - Audit, Deny or Disabled."
  default     = "Deny"
}

locals { // locals for 'mariadb_effect' allowed values
  mariadb_effect_allowed_values = [
    "Audit",
    "Deny",
    "Disabled"
  ]
  // will fail if [mariadb_effect] is invalid:
  validate_mariadb_effect_allowed_value = index(local.mariadb_effect_allowed_values, var.mariadb_effect)
}

variable "cosmosdb_effect" {
  type        = string
  description = "Azure Cosmos DB should disable public network access policy effect - Audit, Deny or Disabled."
  default     = "Deny"
}

locals { // locals for 'cosmosdb_effect' allowed values
  cosmosdb_effect_allowed_values = [
    "Audit",
    "Deny",
    "Disabled"
  ]
  // will fail if [cosmosdb_effect] is invalid:
  validate_cosmosdb_effect_allowed_value = index(local.cosmosdb_effect_allowed_values, var.cosmosdb_effect)
}

variable "sqlmi_aad_effect" {
  type        = string
  description = "Azure SQL Managed Instance should have Azure Active Directory Only Authentication enabled policy effect - Audit, Deny or Disabled."
  default     = "Deny"
}
locals { // locals for 'sqlmi_aad_effect' allowed values
  sqlmi_aad_effect_allowed_values = [
    "Audit",
    "Deny",
    "Disabled"
  ]
  // will fail if [sqlmi_aad_effect] is invalid:
  validate_sqlmi_aad_effect_allowed_value = index(local.sqlmi_aad_effect_allowed_values, var.sqlmi_aad_effect)
}

variable "sqlmi_pub_effect" {
  type        = string
  description = "Azure SQL Managed Instances should disable public network access policy effect - Audit, Deny or Disabled."
  default     = "Deny"
}
locals { // locals for 'sqlmi_pub_effect' allowed values
  sqlmi_pub_effect_allowed_values = [
    "Audit",
    "Deny",
    "Disabled"
  ]
  // will fail if [sqlmi_pub_effect] is invalid:
  validate_sqlmi_pub_effect_allowed_value = index(local.sqlmi_pub_effect_allowed_values, var.sqlmi_pub_effect)
}

variable "key_vault_public_network_effect" {
  type        = string
  description = "Azure Key Vault should disable public network access - Audit, Deny or Disabled."
  default     = "Deny"
}

locals { // locals for 'key_vault_public_network_effect' allowed values
  key_vault_public_network_effect_allowed_values = [
    "Audit",
    "Deny",
    "Disabled"
  ]
  // will fail if [key_vault_public_network_effect] is invalid:
  validate_key_vault_public_network_effect_allowed_value = index(local.key_vault_public_network_effect_allowed_values, var.key_vault_public_network_effect)
}

variable "key_vault_private_link_effect" {
  type        = string
  description = "[Preview]: Azure Key Vaults should use private link - Audit, Deny or Disabled."
  default     = "Deny"
}

locals { // locals for 'key_vault_private_link_effect' allowed values
  key_vault_private_link_effect_allowed_values = [
    "Audit",
    "Deny",
    "Disabled"
  ]
  // will fail if [key_vault_private_link_effect] is invalid:
  validate_key_vault_private_link_effect_allowed_value = index(local.key_vault_private_link_effect_allowed_values, var.key_vault_private_link_effect)
}

variable "storage_public_network_effect" {
  type        = string
  description = "Storage accounts should disable public network access - Audit, Deny or Disabled."
  default     = "Deny"
}

locals { // locals for 'storage_public_network_effectt' allowed values
  storage_public_network_effect_allowed_values = [
    "Audit",
    "Deny",
    "Disabled"
  ]
  // will fail if [storage_public_network_effectt] is invalid:
  validate_storage_public_network_effect_allowed_value = index(local.storage_public_network_effect_allowed_values, var.storage_public_network_effect)
}

variable "log_analytics_ingestion_effect" {
  type        = string
  description = "Log Analytics workspaces should block log ingestion and querying from public networks - Audit, Deny or Disabled."
  default     = "Deny"
}

locals { // locals for 'log_analytics_ingestion_effect' allowed values
  log_analytics_ingestion_effect_allowed_values = [
    "Audit",
    "Deny",
    "Disabled"
  ]
  // will fail if [log_analytics_ingestion_effect] is invalid:
  validate_log_analytics_ingestion_effect_allowed_value = index(local.log_analytics_ingestion_effect_allowed_values, var.log_analytics_ingestion_effect)
}

variable "app_insights_ingestion_effect" {
  type        = string
  description = "Application Insights components should block log ingestion and querying from public networks - Audit, Deny or Disabled."
  default     = "Deny"
}

locals { // locals for 'app_insights_ingestion_effect' allowed values
  app_insights_ingestion_effect_allowed_values = [
    "Audit",
    "Deny",
    "Disabled"
  ]
  // will fail if [app_insights_ingestion_effect] is invalid:
  validate_app_insights_ingestion_effect_allowed_value = index(local.app_insights_ingestion_effect_allowed_values, var.app_insights_ingestion_effect)
}

variable "app_services_vnet_effect" {
  type        = string
  description = "App Service apps should be injected into a virtual network - Audit, Deny or Disabled."
  default     = "Deny"
}

locals { // locals for 'app_services_vnet_effect' allowed values
  app_services_vnet_effect_allowed_values = [
    "Audit",
    "Deny",
    "Disabled"
  ]
  // will fail if [app_services_vnet_effect] is invalid:
  validate_app_services_vnet_effect_allowed_value = index(local.app_services_vnet_effect_allowed_values, var.app_services_vnet_effect)
}

variable "app_services_private_link_effect" {
  type        = string
  description = "App Service apps should use private link - Audit, Deny or Disabled."
  default     = "AuditIfNotExists"
}

locals { // locals for 'app_services_private_link_effect' allowed values
  app_services_private_link_effect_allowed_values = [
    "AuditIfNotExists",
    "Disabled"
  ]
  // will fail if [app_services_private_link_effect] is invalid:
  validate_app_services_private_link_effect_allowed_value = index(local.app_services_private_link_effect_allowed_values, var.app_services_private_link_effect)
}

variable "apim_vnet_effect" {
  type        = string
  description = "API Management services should use a virtual network - Audit or Disabled."
  default     = "Audit"
}

locals { // locals for 'apim_vnet_effect' allowed values
  apim_vnet_effect_allowed_values = [
    "Audit",
    "Disabled"
  ]
  // will fail if [apim_vnet_effect] is invalid:
  validate_apim_vnet_effect_allowed_value = index(local.apim_vnet_effect_allowed_values, var.apim_vnet_effect)
}

variable "app_config_public_network_effect" {
  type        = string
  description = "App Configuration should disable public network access - Audit, Deny or Disabled."
  default     = "Deny"
}

locals { // locals for 'app_config_public_network_effect' allowed values
  app_config_public_network_effect_allowed_values = [
    "Audit",
    "Deny",
    "Disabled"
  ]
  // will fail if [app_config_public_network_effect] is invalid:
  validate_app_config_public_network_effect_allowed_value = index(local.app_config_public_network_effect_allowed_values, var.app_config_public_network_effect)
}

variable "acr_loc_adm_effect" {
  type        = string
  description = "Container registries should have local admin account disabled policy effect - Audit, Deny, Disabled"
  default     = "Audit"
}

locals { // locals for 'acr_loc_adm_effect' allowed values
  acr_loc_adm_effect_allowed_values = [
    "Audit",
    "Deny",
    "Disabled"
  ]
  // will fail if [acr_loc_adm_effect] is invalid:
  validate_acr_loc_adm_effect_allowed_value = index(local.acr_loc_adm_effect_allowed_values, var.acr_loc_adm_effect)
}

variable "sql_private_endpoint_effect" {
  type        = string
  description = "Private endpoint connections on Azure SQL Database should be enabled - Audit or Disabled."
  default     = "Audit"
}

locals { // locals for 'sql_private_endpoint_effect' allowed values
  sql_private_endpoint_effect_allowed_values = [
    "Audit",
    "Disabled"
  ]
  // will fail if [sql_private_endpoint_effect] is invalid:
  validate_sql_private_endpoint_effect_allowed_value = index(local.sql_private_endpoint_effect_allowed_values, var.sql_private_endpoint_effect)
}

variable "service_bus_private_link_effect" {
  type        = string
  description = "Azure Service Bus namespaces should use private link - AuditIfNotExists, or Disabled."
  default     = "AuditIfNotExists"
}

locals { // locals for 'service_bus_private_link_effect' allowed values
  service_bus_private_link_effect_allowed_values = [
    "AuditIfNotExists",
    "Disabled"
  ]
  // will fail if [service_bus_private_link_effect] is invalid:
  validate_service_bus_private_link_effect_allowed_value = index(local.service_bus_private_link_effect_allowed_values, var.service_bus_private_link_effect)
}

variable "service_bus_public_network_effect" {
  type        = string
  description = "Service Bus Namespaces should disable public network access - Audit, Deny or Disabled."
  default     = "Deny"
}

locals { // locals for 'service_bus_public_network_effect' allowed values
  service_bus_public_network_effect_allowed_values = [
    "Audit",
    "Deny",
    "Disabled"
  ]
  // will fail if [service_bus_public_network_effect] is invalid:
  validate_service_bus_public_network_effect_allowed_value = index(local.service_bus_public_network_effect_allowed_values, var.service_bus_public_network_effect)
}

variable "apim_public_network_effect" {
  type        = string
  description = "API Management services should disable public network access - AuditIfNotExists or Disabled."
  default     = "AuditIfNotExists"
}

locals { // locals for 'apim_public_network_effect' allowed values
  apim_public_network_effect_allowed_values = [
    "AuditIfNotExists",
    "Disabled"
  ]
  // will fail if [apim_public_network_effect] is invalid:
  validate_apim_public_network_effect_allowed_value = index(local.apim_public_network_effect_allowed_values, var.apim_public_network_effect)
}

variable "diagnostic_log_categories" {
  type        = list(string)
  description = "Diagnostic log categories for resources"
  default     = null
}

variable "log_analytics_retention" {
  type        = number
  description = "Log Analytics log retention in days 30 - 730."
}

variable "internet_ingestion_enabled" {
  type        = bool
  description = "Should the Log Analytics Workspace support ingestion over the Public Internet"
  default     = false
}

variable "internet_query_enabled" {
  type        = bool
  description = "Should the Log Analytics Workspace support querying over the Public Internet"
  default     = false
}

variable "virtual_network_diagnostic_log_categories" {
  type        = list(string)
  description = "Diagnostic log categories for Virtual Network"
  default     = null
}

variable "azfw_diagnostic_log_categories" {
  type        = list(string)
  description = "Diagnostic log categories for Az Firewall"
  default     = null
}



variable "vm_configs" {
  description = "Configuration for virtual machine"
  type = map(object({
    count               = number
    ip_address_type     = string
    static_ip_addresses = list(string)
  }))
}

variable "shared_vm_config" {
  description = "Shared cofniguration for Virtual Machine"
  type = object({
    subnet_name               = string
    virtual_network_name      = string
    vnet_rg                   = string
    log_analytics_name        = string
    log_analytics_rg          = string
    customized_key_vault_name = string
    resource_group_name       = string
    #    virtual_machine_name          = string # 15 character limit. Additional number issues. 
    virtual_machine_size          = string
    windows_distribution_name     = string
    os_disk_storage_account_type  = string
    storage_os_disk_caching       = string
    delete_os_disk_on_termination = bool
    nb_data_disk                  = number
    data_sa_type                  = string
    data_disk_size_gb             = number
    admin_username                = string
    admin_password                = string
    security_group_name           = string
  })
}

variable "extra_disks" {
  description = "(Optional) List of extra data disks attached to each virtual machine."
  type = list(object({
    name = string
    size = number
  }))
}
# NSG
variable "security_group_name" {
  description = "Network security group name"
  type        = string
  default     = "nsg"
}
