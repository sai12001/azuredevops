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
    name          = string
    tags          = map(string)
    location      = string
    location_abbr = string
  })
}

variable "product_policies" {
  description = "TODO"
  type        = map(string)
  default     = {}
}

variable "binded_domains" {
  description = "TODO"
  type        = list(string)
  default     = ["account", "bet", "racing", "infra", "promotion", "console", "sport"]
}

variable "tags" {
  description = "Tags need to attach to this resource"
  type        = map(string)
  default     = {}
}

variable "apim_dashboard_path" {
  description = "Path to the dashboard template file."
  type        = string
}

variable "apim_dashboard_name" {
  description = "Name of the Azure Shared Dashboard."
  type        = string
}

variable "apim_metric_alert" {
  type = map(object({
    description        = string
    metric_name        = string
    aggregation        = string
    operator           = string
    threshold          = number
    dimension_name     = string
    dimension_operator = string
    dimension_values   = list(string)

  }))
  default = {}
}

variable "ag_short_name" {
  description = "Short Name of the Action Group."
  type        = string
}

variable "vnet_config" {
  description = "The shared vnet configuration"
  type = object({
    name           = string
    resource_group = string
  })
}

variable "apim_enable_action_group" {
  description = "Tag to enable action group alerting"
  type        = bool
  default     = false
}

variable "redis_cache_name" {
  description = "redis cache name"
  type        = string
}

variable "apim_configs" {
  description = "Apim Configurations"
  type = object({
    publisher_name  = string
    publisher_email = string
    sku_name        = string
    base_dns        = string

  })
  default = {
    publisher_name  = "Blackstream"
    publisher_email = "cloud@blackstream.com.au"
    sku_name        = "Developer_1"
    base_dns        = "blackstream.com.au"
  }

}

variable "log_analytics_retention" {
  description = "Rentention days for log analytics"
  type        = number
  default     = 30
}

variable "certificates" {
  type = map(object({
    encoded_certificate = string
    store_name          = string
  }))

  default = {}
}
