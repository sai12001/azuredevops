variable "virtual_network_name" {
  description = "Name of the Virtual Network"
  type        = string
}

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
    location_abbr = string
  })
}

variable "tags" {
  description = "Tags need to attach to this resource group"
  type        = map(string)
  default     = {}
}

variable "enable_http2" {
  description = "Whether to enable http2 or not"
  type        = bool
  default     = true
}

variable "sku_name" {
  description = "SKU configuration object"
  type        = string
}

variable "sku_capacity" {
  description = "SKU configuration object"
  type        = string
}

variable "appgw_private" {
  description = "Set true to private Application Gateway. When `true`, the default http listener will listen on private IP instead of the public IP."
  type        = bool
  default     = false
}

variable "appgw_private_ip" {
  description = "Private IP for Application Gateway. Used when variable `appgw_private` is set to `true`."
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "The Subnet ID for attaching the Application Gateway."
  type        = string
}

variable "vnet_config" {
  description = "The shared vnet configuration"
  type = object({
    name           = string
    resource_group = string
  })
}

variable "frontend_port_settings" {
  description = "Frontend port settings. Each port setting contains the name and the port for the frontend port."
  type = list(object({
    name = string
    port = number
  }))
}

variable "force_firewall_policy_association" {
  description = "Enable if the Firewall Policy is associated with the Application Gateway."
  type        = bool
  default     = false
}

variable "waf_configuration" {
  description = "WAF configuration object (only available with WAF_v2 SKU)"

  type = object({
    enabled                  = optional(bool)
    file_upload_limit_mb     = optional(number)
    firewall_mode            = optional(string)
    max_request_body_size_kb = optional(number)
    request_body_check       = optional(bool)
    rule_set_type            = optional(string)
    rule_set_version         = optional(string)
    disabled_rule_group = optional(list(object({
      rule_group_name = string
      rules           = optional(list(string))
    })))
    exclusion = optional(list(object({
      match_variable          = string
      selector                = optional(string)
      selector_match_operator = optional(string)
    })))
  })
  default = {}
}

variable "ssl_policy" {
  description = "Application Gateway SSL configuration. List https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway#disabled_protocols"
  type = object({
    disabled_protocols   = optional(list(string))
    policy_type          = optional(string)
    policy_name          = optional(string)
    cipher_suites        = optional(list(string))
    min_protocol_version = optional(string)
  })
  default = null
}

variable "ssl_profile" {
  description = "Application Gateway SSL profile. Default profile is used when this variable is set to null"
  type = object({
    name                             = string
    trusted_client_certificate_names = optional(list(string))
    verify_client_cert_issuer_dn     = optional(bool)
    ssl_policy = optional(object({
      disabled_protocols   = optional(list(string))
      policy_type          = optional(string)
      policy_name          = optional(string)
      cipher_suites        = optional(list(string))
      min_protocol_version = optional(string)
    }))
  })
  default = null
}

variable "authentication_certificates_configs" {
  description = <<EOD
List of objects with authentication certificates configurations. 
The path to a base-64 encoded certificate is expected in the 'data' attribute:
  ```
  data = filebase64("./file_path")
  ```
EOD
  type = list(object({
    name = string
    data = string
  }))
  default = []
}

variable "trusted_client_certificates_configs" {
  description = <<EOD
List of objects with trusted client certificates configurations.
The path to a base-64 encoded certificate is expected in the 'data' attribute:
```
data = filebase64("./file_path")
```
EOD
  type = list(object({
    name = string
    data = string
  }))
  default = []
}

variable "autoscaling_parameters" {
  description = "Map containing autoscaling parameters. Must contain at least min_capacity"
  type = object({
    min_capacity = number
    max_capacity = optional(number)
  })
  default = null
}

variable "appgw_backend_http_settings" {
  description = "List of objects including backend http settings configurations."
  type = list(object({
    name     = string
    port     = optional(number)
    protocol = optional(string)

    path       = optional(string)
    probe_name = optional(string)

    cookie_based_affinity               = optional(string)
    affinity_cookie_name                = optional(string)
    request_timeout                     = optional(number)
    host_name                           = optional(string)
    pick_host_name_from_backend_address = optional(bool)
    trusted_root_certificate_names      = optional(list(string))
    authentication_certificate          = optional(string)

    connection_draining_timeout_sec = optional(number)
  }))
}

variable "appgw_http_listeners" {
  description = "List of objects with HTTP listeners configurations and custom error configurations."
  type = list(object({
    name = string

    frontend_ip_configuration_name = optional(string)
    frontend_port_name             = optional(string)
    host_name                      = optional(string)
    host_names                     = optional(list(string))
    protocol                       = optional(string)
    require_sni                    = optional(bool)
    ssl_certificate_name           = optional(string)
    ssl_certificate_id             = optional(string)
    ssl_profile_name               = optional(string)
    firewall_policy_id             = optional(string)
    /* # require to configure container and blob with custom error message. 
    custom_error_configuration = optional(list(object({
      status_code           = string
      custom_error_page_url = string
    })))
    */
  }))
}

variable "appgw_backend_pools" {
  description = "List of objects with backend pool configurations."
  type = list(object({
    name         = string
    fqdns        = optional(list(string))
    ip_addresses = optional(list(string))
  }))
}

variable "ssl_certificates_configs" {
  description = <<EOD
List of objects with SSL certificates configurations.
The path to a base-64 encoded certificate is expected in the 'data' attribute:
```
data = filebase64("./file_path")
```
EOD
  type = list(object({
    name                = string
    data                = optional(string)
    password            = optional(string)
    key_vault_secret_id = optional(string)
  }))
  default = []
}

variable "trusted_root_certificate_configs" {
  description = "List of trusted root certificates. `file_path` is checked first, using `data` (base64 cert content) if null. This parameter is required if you are not using a trusted certificate authority (eg. selfsigned certificate)."
  type = list(object({
    name                = string
    data                = optional(string)
    file_path           = optional(string)
    key_vault_secret_id = optional(string)
  }))
  default = []
}

variable "appgw_routings" {
  description = "List of objects with request routing rules configurations. With AzureRM v3+ provider, `priority` attribute becomes mandatory."
  type = list(object({
    name                        = string
    rule_type                   = optional(string)
    http_listener_name          = optional(string)
    backend_address_pool_name   = optional(string)
    backend_http_settings_name  = optional(string)
    url_path_map_name           = optional(string)
    redirect_configuration_name = optional(string)
    rewrite_rule_set_name       = optional(string)
    priority                    = optional(number)
  }))
}

variable "appgw_rewrite_rule_set" {
  description = "List of rewrite rule set objects with rewrite rules."
  type = list(object({
    name = string
    rewrite_rules = list(object({
      name          = string
      rule_sequence = string

      conditions = optional(list(object({
        variable    = string
        pattern     = string
        ignore_case = optional(bool)
        negate      = optional(bool)
      })))

      response_header_configurations = optional(list(object({
        header_name  = string
        header_value = string
      })))

      request_header_configurations = optional(list(object({
        header_name  = string
        header_value = string
      })))

      url_reroute = optional(object({
        path         = optional(string)
        query_string = optional(string)
        components   = optional(string)
        reroute      = optional(bool)
      }))
    }))
  }))
  default = []
}

variable "appgw_probes" {
  description = "List of objects with probes configurations."
  type = list(object({
    name     = string
    host     = optional(string)
    port     = optional(number)
    interval = optional(number)
    path     = optional(string)
    protocol = optional(string)
    timeout  = optional(number)

    unhealthy_threshold                       = optional(number)
    pick_host_name_from_backend_http_settings = optional(bool)
    minimum_servers                           = optional(number)

    match = optional(object({
      body        = optional(string)
      status_code = optional(list(string))
    }))
  }))
  default = []
}

variable "appgw_url_path_map" {
  description = "List of objects with URL path map configurations."
  type = list(object({
    name = string

    default_backend_address_pool_name   = optional(string)
    default_redirect_configuration_name = optional(string)
    default_backend_http_settings_name  = optional(string)
    default_rewrite_rule_set_name       = optional(string)

    path_rules = list(object({
      name = string

      backend_address_pool_name  = optional(string)
      backend_http_settings_name = optional(string)
      rewrite_rule_set_name      = optional(string)

      paths = optional(list(string))
    }))
  }))
  default = []
}

variable "appgw_redirect_configuration" {
  description = "List of objects with redirect configurations."
  type = list(object({
    name = string

    redirect_type        = optional(string)
    target_listener_name = optional(string)
    target_url           = optional(string)

    include_path         = optional(bool)
    include_query_string = optional(bool)
  }))
  default = []
}

variable "user_assigned_identity_id" {
  description = "User assigned identity id assigned to this resource."
  type        = string
  default     = null
}

variable "disable_waf_rules_for_dev_portal" {
  description = "Whether to disable some WAF rules if the APIM developer portal is hosted behind this Application Gateway. See locals.tf for the documentation link."
  type        = bool
  default     = false
}

variable "sku" {
  description = "The SKU of the Public IP. Accepted values are Basic and Standard. Defaults to Basic. Changing this forces a new resource to be created."
  type        = string
  default     = "Standard"
}