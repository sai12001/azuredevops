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

variable "profile_name" {
  type        = string
  description = "Name of the profile name"
}

variable "profile_capacity_maximum" {
  type        = number
  description = "profile capacity maximum"
}

variable "autoscale_rule" {
  type = map(object({
    metric_name      = string
    time_grain       = string
    statistic        = string
    time_window      = string
    time_aggregation = string
    operator         = string
    threshold        = number
    metric_namespace = string

    direction = string
    type      = string
    value     = number
    cooldown  = string
  }))
  default = {}
}

variable "email_send_to_admin" {
  type        = bool
  description = "send to subscription administrator"
  default     = true
}

variable "email_send_to_co_admin" {
  type        = bool
  description = "send to subscription co administrator"
  default     = true
}

variable "email_custom_emails" {
  type        = list(string)
  description = "List of custom emails"
  default     = ["cloud@blackstream.com.au"]
}

variable "resource_id" {
  type        = string
  description = "ID of the resource"
  default     = ""
}

variable "tags" {
  description = "Tags need to attach to this resource"
  type        = map(string)
  default     = {}
}

variable "autoscale_name" {
  type        = string
  description = "Name of the auto scaling setting"
  default     = ""
}

variable "enable_notification" {
  type        = bool
  description = "Enable notification for auto scaling"
  default     = false
}

variable "rulelist" {
  type        = list(string)
  description = "Enable data_out rule for auto scaling"
  default     = ["Memory","CPU"]
}

variable "enable_autoscaling" {
  type        = bool
  description = "Enable auto scaling"
  default     = true
}