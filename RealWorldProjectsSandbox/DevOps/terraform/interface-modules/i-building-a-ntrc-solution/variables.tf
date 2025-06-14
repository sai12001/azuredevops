#TODO Add validation rules for this variable
variable "context" {
  description = "The environment context for this operation"
  type = object({
    product       = string
    environment   = string
    location      = string
    location_abbr = string
  })
}

variable "with_app_service_plans" {
  description = "TODO"
  type = list(object({
    asp_name                 = string
    sku_name                 = string
    subnet_cidr              = string
    per_site_scaling         = optional(bool)
    enable_autoscaling       = optional(bool)
    profile_capacity_maximum = optional(number)
    rulelist                 = optional(list(string))
    enable_notification      = optional(bool)
  }))
  default = []
}


variable "with_solution_configs" {
  description = "value"
  type = object({
    team_name     = string
    solution_name = string
    domain_name   = string
  })
  validation {
    condition     = can(regex("^[a-z]{2,12}(?:-[a-z]{2,12})*$", var.with_solution_configs.solution_name))
    error_message = "Solution name must follow format xxx[-xx] with max length of 12 before and after hypen(-)."
  }
  validation {
    condition     = contains(["ntrc"], var.with_solution_configs.domain_name)
    error_message = "Domain name must be ntrc.[Case Sensitive]"
  }
  validation {
    condition     = contains(["sharpie", "phoenix", "cloudops", "unicorn", "avengers", "whoknows", "forcefour"], var.with_solution_configs.team_name)
    error_message = "Team name must be one of following: sharpie, phoenix, cloudops,unicorn, avengers, forcefour.[Case Sensitive]"
  }
}

variable "with_apps_configs" {
  description = "value"
  type = list(object({
    app_name             = string
    asp_name             = string
    app_type             = optional(string)
    worker_count         = optional(number)
    exposed_to_apim      = optional(bool)
    enable_local_logging = optional(bool)
    cors_allowed_origins = optional(list(string))
    plain_text_settings  = map(string)
    access_rules = optional(list(object({
      action                    = string
      name                      = string,
      headers                   = optional(list(string))
      priority                  = number
      service_tag               = optional(string)
      ip_address                = optional(string)
      virtual_network_subnet_id = optional(string)
    })))
    secure_settings = list(object({
      domain      = string
      secret_name = string
      config_name = string
    }))
  }))

  validation {
    condition     = alltrue([for app in var.with_apps_configs : contains(["webapp", "fnapp"], coalesce(app.app_type, "fnapp"))])
    error_message = "App type only support fnapp and webapp"
  }
}
