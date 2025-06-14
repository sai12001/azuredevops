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
  description = "The app service plan to host this function app"
  type        = string
}

variable "function_app_name" {
  description = "The function app name"
  type        = string
}


variable "storage_account" {
  description = "The storage account to config function apps"
  type = object({
    connection_string = string
    name              = string
  })
  sensitive = true
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

variable "cors_allowed_origins" {
  description = "A List of origins which should be able to make cross-origin calls"
  type        = list(string)
  default     = []
}

variable "worker_count" {
  description = "The max worker count if per site scaling enabled"
  type        = number
  default     = null

}

variable "subnet_id" {
  description = "The subnet id where the app will be connected to"
  type        = string
  default     = ""
}

variable "exposed_to_apim" {
  description = "Whethere expose the function key to apim"
  type        = bool
  default     = false
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

variable "enable_local_logging" {
  description = "Flag for default app logging for debugging"
  type        = bool
  default     = false
}

variable "target_keyvault_id" {
  description = "Specfic the key vault to use"
  type        = string
  default     = null
}

variable "log_analytics_retention" {
  description = "Rentention days for log analytics"
  type        = number
  default     = 30
}

variable "health_check_path" {
  description = "path of the health check page"
  type        = string
  default     = null
}


variable "privatelink" {
  description = "Configuration for private link"
  type = object({
    subnet_id           = string
    private_dns_zone_id = string
  })
  default = null
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
