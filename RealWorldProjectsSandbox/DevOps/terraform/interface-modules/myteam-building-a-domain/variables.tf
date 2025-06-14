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

variable "with_domain_configs" {
  description = "TODO"
  type = object({
    team_name   = list(string)
    domain_name = string
  })
  validation {
    condition     = contains(["frontend", "account", "racing", "bet", "promotion", "sport", "infra", "whatever", "core", "console", "utilities"], var.with_domain_configs.domain_name)
    error_message = "Domain name must be one of following: account, racing, bet, promotion, sport, infra, core, console, frontend, utilities.[Case Sensitive]"
  }
  validation {
    condition     = alltrue([for t in var.with_domain_configs.team_name : length(t) < 24])
    error_message = "Team name should not be more than 24 characters"
  }
}

variable "needs_a_key_vault" {
  description = "TODO"
  type        = bool
}

variable "needs_app_service_plans" {
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

variable "needs_an_eventhub_namespace" {
  description = "TODO"
  type = object({
    sku            = optional(string)
    capacity       = optional(number)
    zone_redundant = optional(bool)
  })
  default = null
}

variable "needs_cosmos_dbs" {
  description = "value"
  type = object({
    account_name                    = string
    primary_location                = string
    primary_location_zone_redundant = bool
    extra_locaions = optional(list(object({
      location       = string
      priority       = number
      zone_redundant = bool
    })))
    sql_databases = optional(list(object({
      name           = string
      max_throughput = optional(number)
      containers = optional(list(object({
        name               = string
        max_throughput     = optional(number)
        indexing_mode      = optional(string)
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
    })))
  })
  default = null
}


variable "needs_postgresql_server" {
  description = "value"
  type = object({
    server_version    = optional(string)
    server_username   = optional(string)
    server_storage_mb = optional(number)
    server_sku        = optional(string)
    databases = optional(list(object({
      name      = string
      charset   = optional(string)
      collation = optional(string)
    })))
  })
  default = null

}

variable "tags" {
  description = "Tags need to attach to this resource"
  type        = map(string)
  default     = {}
}

variable "enable_autoscaling" {
  type        = bool
  description = "Enable auto scaling"
  default     = true
}

variable "need_servicebus_namespace_auth_rules" {
  description = "service bus namespace auth rules"
  type        = list(string)
  default     = []
  validation {
    condition     = alltrue([for r in var.need_servicebus_namespace_auth_rules : can(regex("^[a-z]{2,12}(?:-[a-z]{2,12})*$", r))])
    error_message = "Rule names must follow format xx[-xx] with max length of 12 before and after hypen(-)."
  }
}

variable "need_tbs_db_access" {
  description = "domain needs tbs db access"
  type = object({
    sqlmi_instance = optional(string)
    databases = optional(list(object({
      name = string
    })))
  })
  default = null
}

# variable "needs_application_gateway" {
#   description = "specify whether domain needs a Application Gateway resource"
#   type = object({
#     sku_name              = string
#     sku_capacity          = string
#     public_ip_address_id  = string

#     appgw_backend_http_settings = list(object({
#       name                  = string
#       cookie_based_affinity = string
#       path                  = string
#       port                  = number
#       protocol              = string
#       request_timeout       = number
#     }))

#     appgw_backend_pools = list(object({
#       name  = string
#       fqdns = list(string)  
#     }))

#     appgw_routings = list(object({
#       name                        = string
#       rule_type                   = string
#       http_listener_name          = string
#       backend_address_pool_name   = string
#       backend_http_settings_name  = string
#     }))

#     appgw_http_listeners = list(object({
#       name                            = string
#       frontend_ip_configuration_name = optional(string)
#       frontend_port_name             = optional(string)
#       host_name                      = optional(string)
#       host_names                     = optional(list(string))
#       protocol                       = optional(string)
#       require_sni                    = optional(bool)
#       ssl_certificate_name           = optional(string)
#       ssl_profile_name               = optional(string)
#       firewall_policy_id             = optional(string)

#       custom_error_configuration = optional(list(object({
#         status_code           = string
#         custom_error_page_url = string
#       })))
#     }))

#     frontend_port_settings = list(object({
#       name = string
#       port = number
#     }))

#     ssl_certificates_configs = list(object({
#       name      = string
#       data      = string
#       password  = string
#     }))

#     ssl_policy = object({
#       policy_type = string
#       policy_name = string
#     })

#     appgw_rewrite_rule_set = list(object({
#       name  = string
#       rewrite_rules = list(object({
#         name          = string
#         rule_sequence = number

#         conditions    = list(object({
#           ignore_case = bool
#           negate      = bool
#           pattern     = string
#           variable    = string
#         }))

#         response_header_configuration = optional(list(object({
#           header_name   = string
#           header_value  = string 
#         })))

#         request_header_configuration = optional(list(object({
#           header_name   = string
#           header_value  = string 
#         })))

#         url_reroute = optional(object({
#           path          = string
#           query_string  = string
#           reroute       = bool
#         }))
#       }))
#     }))

#     appgw_url_path_map = list(object({
#       name                                = string
#       default_backend_http_settings_name  = string
#       default_backend_address_pool_name   = string
#       default_rewrite_rule_set_name       = string

#       path_rules = list(object({
#         name                        = string
#         backend_address_pool_name   = string
#         backend_http_settings_name  = string
#         rewrite_rule_set_name       = string
#         paths                       = list(string)
#       }))
#     }))

#     autoscaling_parameters = object({
#       min_capacity  = number
#       max_capacity  = number
#     })
#   })
# }
