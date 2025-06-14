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

variable "sku" {
  description = "	Signalr SKU"
  type = object({
    name     = string,
    capacity = number
  })

  default = {
    "capacity" : 1,
    "name" : "Free_F1"
  }
}

variable "connectivity_logs_enabled" {
  description = "If connectivity logs should be enabled"
  type        = bool
  default     = true
}

variable "allowed_origins" {
  description = "A List of origins which should be able to make cross-origin calls"
  type        = list(string)
  default     = []
}

variable "messaging_logs_enabled" {
  description = "If messaging logs should be enabled"
  type        = bool
  default     = true
}

variable "live_trace_enabled" {
  description = "If live trace should be enabled"
  type        = bool
  default     = true
}

variable "service_mode" {
  description = "Specify the service mode"
  type        = string
  default     = "Default"
}

variable "category_pattern" {
  description = "A List of categories to match on"
  type        = list(string)
  default     = ["*"]
}

variable "event_pattern" {
  description = "A List of events to match on"
  type        = list(string)
  default     = ["*"]
}

variable "hub_pattern" {
  description = "A List of hubs to match on"
  type        = list(string)
  default     = ["*"]
}

variable "url_template" {
  description = "The upstream URL Template. This can be a url or a template"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags need to attach to this resource"
  type        = map(string)
  default     = {}
}

variable "metric_alert" {
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

variable "enable_action_group" {
  description = "Enable Action Group Creation"
  type        = bool
  default     = false
}


variable "ag_short_name" {
  description = "Short Name of the Action Group."
  type        = string
}

variable "log_analytics_retention" {
  description = "Rentention days for log analytics"
  type        = number
  default     = 30
}
