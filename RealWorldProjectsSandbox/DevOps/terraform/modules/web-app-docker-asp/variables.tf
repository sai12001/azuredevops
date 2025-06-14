variable "context" {
  description = "The environment context for this operation"
  type = object({
    product       = string
    environment   = string
    location      = string
    location_abbr = string
  })
}

variable "app_service_plan_id" {
  description = "The app service plan to host this web app"
  type        = string
}

variable "webapp_name" {
  description = "The web app name"
  type        = string
}

variable "application_insights" {
  description = "The application insights information"
  type = object({
    instrumentation_key = string
    connection_string   = string
  })
}

variable "resource_group" {
  description = "Resoruce group object where this resource will deploy to, it suppose pass from resource group output"
  type = object({
    name     = string
    location = string
    tags     = map(string)
  })
}


variable "domain" {
  description = "TODO"
  type        = string
}

variable "solution_name" {
  description = "TODO"
  type        = string
}

variable "tags" {
  description = "Tags need to attach to this resource group"
  type        = map(string)
  default     = {}
}


variable "app_settings" {
  description = "TODO"
  type        = map(string)
  default     = {}
}
variable "secure_settings" {
  description = "TODO"
  type = list(object({
    domain      = string
    secret_name = string
    config_name = string
  }))
  default = []
}


variable "worker_count" {
  description = "TODO"
  type        = number
  default     = null

}

variable "subnet_id" {
  description = "TODO"
  type        = string
  default     = ""
}


variable "enable_local_logging" {
  description = "Flag for default app logging for debugging"
  type        = bool
  default     = false
}

variable "log_analytics_retention" {
  description = "Rentention days for log analytics"
  type        = number
  default     = 30

}

variable "access_rules" {
  description = "The access rules for this app service"
  type = list(object({
    action                    = string
    name                      = string,
    headers                   = optional(list(string))
    priority                  = number
    service_tag               = optional(string)
    ip_address                = optional(string)
    virtual_network_subnet_id = optional(string)
  }))
  default = []
}

variable "cors_allowed_origins" {
  description = "A List of origins which should be able to make cross-origin calls"
  type        = list(string)
  default     = []
}

variable "health_check_path" {
  description = "path of the health check page"
  type        = string
  default     = null
}

variable "connection_strings" {
  description = "Conection string settings"
  type = list(object({
    domain      = string
    config_name = string
    type        = string
    secret_name = string
  }))
  default = []
}
variable "required_custom_dns" {
  description = "sub dmoain"
  type = object({
    sub_domain = optional(string)
  })
  default = {}
}
variable "base_dns" {
  description = "base dns"
  type        = string
  default     = "blackstream.com.au"
}
