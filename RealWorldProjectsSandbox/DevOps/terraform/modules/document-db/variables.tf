variable "context" {
  description = "The environment context for this operation"
  type = object({
    product       = string
    environment   = string
    location      = string
    location_abbr = string
  })
}

variable "domain" {
  description = "TODO"
  type        = string
}

variable "resource_group" {
  description = "Resoruce group object where this resource will deploy to, it suppose pass from resource group output"
  type = object({
    name     = string
    location = string
    tags     = map(string)
  })
}

variable "extra_cosmosdb_az_regions" {
  description = "The region where cosmosdb will configure it is data resiliencey, normally extra read region."
  type = map(object({
    location       = string
    priority       = number
    zone_redundant = bool
  }))
  default = {}

  validation {
    condition     = alltrue([for region in var.extra_cosmosdb_az_regions : region.priority >= 1])
    error_message = "Priority must be larger than 0."
  }
}

variable "cosmos_name" {
  description = "The name of the cosmosdb account, injected from interface module, developer have no control over this"
  type        = string
}

variable "cosmosdb_account" {
  description = "Config for cosmosdb"
  type = object({
    primary_location                = string
    primary_location_zone_redundant = optional(string)
    consistency_level               = optional(string)
    offer_type                      = optional(string)
    kind                            = optional(string)
  })

}


variable "cosmosdb_sqldbs" {
  description = "The sql databases and its containers"
  type = list(object({
    name           = string
    max_throughput = optional(number)
    containers = optional(list(object({
      name               = string
      indexing_mode      = optional(string)
      max_throughput     = optional(number)
      partition_key_path = string
      included_paths     = optional(list(string))
      excluded_paths     = optional(list(string))
      unique_keys        = optional(list(string))
      default_ttl        = optional(number)
      triggers = optional(list(object({
        name      = string
        body      = string
        operation = string
        type      = string
      })))
      stored_procedures = optional(list(object({
        name = string
        body = string
      })))
      functions = optional(list(object({
        name = string
        body = string
      })))
    })))
  }))
  default = []
}

variable "tags" {
  description = "Tags need to attach to this resource group"
  type        = map(string)
  default     = {}
}

variable "privatelink" {
  description = "Configuration for private link"
  type = object({
    subnet_id           = string
    private_dns_zone_id = string
  })
  default = null
}

variable "vnet_config" {
  description = "The shared vnet configuration"
  type = object({
    name           = string
    resource_group = string
  })
}

variable "cosmo_db_metrics" {
  description = "Metrics list for the Cosmos DB"
  type = map(object({
    description        = string
    metric_name        = string
    metric_namespace   = string
    aggregation        = string
    operator           = string
    threshold          = number
    dimension_name     = string
    dimension_operator = optional(string)
    dimension_values   = optional(list(string))

  }))
  default = {}
}

variable "subnets" {
  description = "All the subnet names"
  type = list(string)
  default = []
}

variable "log_analytics_retention" {
  description = "Rentention days for log analytics"
  type        = number
  default     = 30

}