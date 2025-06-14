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


variable "vnet" {
  description = "Vnet configuration"
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

variable "vnet_ntrc" {
  description = "NTRC Vnet configuration"
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

variable "enable_ntrc" {
  description = "Flag to tell will have NTRC in this environment or not"
  type        = bool
  default     = false
}

variable "privatelink_dns_zones" {
  description = "The supported private link dns zones"
  type        = list(string)
  default     = []
}

variable "ntrc_sql_mi" {
  description = "configuration for ntrc sql mi"
  type = object({
    instance_name                = string
    administrator_login          = string
    db_user                      = string
    collation                    = string
    vcores                       = number
    storage_account_type         = string
    storage_size_in_gb           = number
    proxy_override               = string
    timezone_id                  = string
    license_type                 = string
    sku_name                     = string
    subnet_name                  = string
    public_data_endpoint_enabled = bool
    network_security_group_rules = list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = optional(string)
      destination_port_ranges    = optional(list(string))
      source_address_prefix      = string
      destination_address_prefix = string
      description                = string
    }))
  })
}
            
variable "log_analytics_retention" {
  type        = number
  description = "Log Analytics log retention in days 30 - 730."
  default     = 30
}