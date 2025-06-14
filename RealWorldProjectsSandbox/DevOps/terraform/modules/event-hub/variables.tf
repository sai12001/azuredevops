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

variable "team" {
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

variable "tags" {
  description = "Tags need to attach to this resource"
  type        = map(string)
  default     = {}
}

variable "eventhub_namespace" {
  description = "TODO"
  type = object({
    sku            = optional(string)
    capacity       = optional(number)
    zone_redundant = optional(bool)
  })
  default = null
}

variable "eventhubs" {
  description = "TODO"
  type = list(object({
    domain_name = string
    name        = string
    # validation, maxium number is 32
    partition_count = optional(number)
    retention_day   = optional(number)
    consumer_groups = optional(list(object({
      name          = string
      user_metadata = string
    })))
    auth_rules = optional(list(object({
      name   = string
      listen = optional(bool)
      send   = optional(bool)
      manage = optional(bool)
    })))
  }))
  default = []
}

variable "consumer_groups" {
  description = "TODO"
  type = list(object({
    domain_name   = string
    eventhub_name = string
    name          = string
    user_metadata = optional(string)
  }))
  default = []
}

variable "auth_rules" {
  description = "TODO"
  type = list(object({
    domain_name   = string
    eventhub_name = string
    name          = string
    listen        = optional(bool)
    send          = optional(bool)
    manage        = optional(bool)
  }))
  default = []
}


variable "eventhub_metric_alerts" {
  description = "Metrics list for the Event Hub"
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


variable "log_analytics_retention" {
  description = "Rentention days for log analytics"
  type        = number
  default     = 30

}