variable "context" {
  description = "The environment context for this operation"
  type = object({
    product       = string
    environment   = string
    location      = string
    location_abbr = string
  })
}

variable "resource_group" {
  description = "Resoruce group object where this resource will deploy to, it suppose pass from resource group output"
  type = object({
    name          = string
    tags          = map(string)
    location      = string
    location_abbr = optional(string)
  })
}

variable "metric_alert" {
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

variable "resource_id" {
  description = "List of resource id"
  type        = string
}

variable "enable_action_group" {
  description = "Enable Action Group Creation"
  type        = bool
  default     = false
}

variable "metric_alert_name" {
  description = "Name of the Metric Alert."
}

variable "domain" {
  description = "Domain Name."
}

variable "action_group_id" {
  description = "Action Group ID"
  type        = string
}

variable "tags" {
  description = "Tags"
  type        = map(string)
  default     = {}
}
