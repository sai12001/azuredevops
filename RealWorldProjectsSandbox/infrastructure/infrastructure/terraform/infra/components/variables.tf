variable "product" {
  description = "Which product this deploy is targeting for. Injected by environment settings"
  type        = string
  default     = "ng"
}
variable "environment" {
  description = "Which environment we are deploying, supporting dev, stg, pef, prd. This value will be auto injected by terragrunt"
  type        = string
}
variable "location" {
  description = "Deployment location for cluster, support Australia East, Australia Southeast etc"
  type        = string
  default     = "australiaeast"
}
variable "location_abbr" {
  description = "Deployment location for cluster, support Australia East, Australia Southeast etc"
  type        = string
  default     = "eau"
}

variable "domain_name" {
  description = "The domain name for infra component"
  type        = string
  default     = "infra"
}
variable "team_name" {
  description = "The team name for infra component"
  type        = string
  default     = "cloudops"
}

variable "shared_vnet_config" {
  description = "The configuration for shared vnet"
  type = object({
    name           = string
    resource_group = string
  })
}

variable "rg_infra" {
  description = "The resource group information needed for downstream"
  type = object({
    location      = string
    name          = string
    location_abbr = string
    tags          = map(string)
  })
}


variable "acr_config" {
  description = "The ACR configuration for environment"
  type = object({
    sku           = string
    admin_enabled = bool
  })
}

variable "signalr_config" {
  description = "Configuration for signalR"
  type = object({
    allowed_origins           = list(string)
    connectivity_logs_enabled = bool
    messaging_logs_enabled    = bool
    live_trace_enabled        = bool
    service_mode              = string
    sku = object({
      capacity = number
      name     = string
    })

    category_pattern    = list(string)
    event_pattern       = list(string)
    hub_pattern         = list(string)
    url_template        = string
    enable_action_group = bool
    dashboard_name      = string
  })
}

variable "redis_config" {
  type = object({
    capacity = number
    family   = string
    sku_name = string
  })
  validation {
    condition     = contains(["c", "p"], var.redis_config.family)
    error_message = "family name must be one of following: c, p]"
  }
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.redis_config.sku_name)
    error_message = "sku name must be one of following: Basic, Standard, Premium]"
  }
}

variable "signalr_metric_alert" {
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

variable "apim_config" {
  type = object({
    publisher_name  = string
    publisher_email = string
    sku_name        = string
    base_dns        = string

    dashboard_name      = string
    enable_action_group = bool
    ag_short_name       = string

    enable_email_receiver = bool
    email_name            = string
    email_address         = string

    enable_sms_receiver = bool
    sms_name            = string
    sms_phone_number    = string

    enable_voice_receiver = bool
    voice_name            = string
    voice_phone_number    = string
  })


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

variable "action_groups" {
  description = "Action Group Variables"
  type = map(object({
    enable_email_receiver              = bool
    enable_sms_receiver                = optional(bool)
    enable_voice_receiver              = optional(bool)
    enable_automation_runbook_receiver = optional(bool)
    enable_azure_function_receiver     = optional(bool)
    enable_event_hub_receiver          = optional(bool)
    enable_logic_app_receiver          = optional(bool)
    enable_webhook_receiver            = optional(bool)
    ag_short_name                      = string
    email = optional(object({
      email_name    = string
      email_address = string
    }))

    sms = optional(object({
      sms_name         = string
      sms_phone_number = number
    }))

    voice = optional(object({
      voice_name         = string
      voice_phone_number = number
    }))

    automation_runbook = optional(object({
      name                    = string
      automation_account_id   = string
      runbook_name            = string
      webhook_resource_id     = string
      is_global_runbook       = bool
      service_uri             = string
      use_common_alert_schema = bool
    }))

    azure_function_receiver = optional(object({
      name                     = string
      function_app_resource_id = string
      function_name            = string
      http_trigger_url         = string
      use_common_alert_schema  = bool
    }))

    event_hub_receiver = optional(object({
      name                    = string
      event_hub_id            = string
      use_common_alert_schema = bool
    }))

    logic_app_receiver = optional(object({
      name                    = string
      resource_id             = string
      callback_url            = string
      use_common_alert_schema = bool
    }))

    webhook_receiver = optional(object({
      name                    = string
      service_uri             = string
      use_common_alert_schema = bool
    }))

  }))

}


variable "servicebus_config" {
  description = "Configuration for shared service bus"
  type = object({
    sku = string
  })
}

variable "sql_mi" {
  description = "configuration for sql mi"
  type = object({
    instance_name                = string
    resource_group               = string
    administrator_login          = string
    db_user                      = string
    collation                    = string
    vcores                       = number
    storage_account_type         = string
    storage_size_in_gb           = number
    proxy_override               = string
    timezone_id                  = string
    license_type                 = string
    sku_name                     = string
    subnet_name                  = string
    public_data_endpoint_enabled = bool
    network_security_group_rules = list(object({
      name                       = string                 //"allow_management_inbound"
      priority                   = number                 //101
      direction                  = string                 //"Inbound"
      access                     = string                 //"Allow"
      protocol                   = string                 //"Tcp"
      source_port_range          = string                 // "*"
      destination_port_range     = optional(string)       // "*"
      destination_port_ranges    = optional(list(string)) //["9000", "9003", "1438", "1440", "1452"]
      source_address_prefix      = string                 //"*"
      destination_address_prefix = string                 //"*"
      description                = string
    }))
  })
}

variable "sql_mi_load_test" {
  description = "configuration for sql mi"
  type = object({
    instance_name                = string
    resource_group               = string
    administrator_login          = string
    db_user                      = string
    collation                    = string
    vcores                       = number
    storage_account_type         = string
    storage_size_in_gb           = number
    proxy_override               = string
    timezone_id                  = string
    license_type                 = string
    sku_name                     = string
    public_data_endpoint_enabled = bool
    subnet_name                  = string
    network_security_group_rules = list(object({
      name                       = string                 //"allow_management_inbound"
      priority                   = number                 //101
      direction                  = string                 //"Inbound"
      access                     = string                 //"Allow"
      protocol                   = string                 //"Tcp"
      source_port_range          = string                 // "*"
      destination_port_range     = optional(string)       // "*"
      destination_port_ranges    = optional(list(string)) //["9000", "9003", "1438", "1440", "1452"]
      source_address_prefix      = string                 //"*"
      destination_address_prefix = string                 //"*"
      description                = string
    }))
  })
  default = null
}

variable "databricks" {
  description = "configuration for databricks"
  type = object({
    databricks_workspace_name = string
    databricks_sku            = string
    resource_group            = string
    private_subnet_name       = string
    public_subnet_name        = string
    storage_account_sku_name  = string
    driver_node_type_id       = string
    spark_version             = string
    vnet_name                 = string
    vnet_resource_group       = string
    domain_name               = string
    branch                    = string

    network_security_group_rules = list(object({
      name                       = string                 //"allow_management_inbound"
      priority                   = number                 //101
      direction                  = string                 //"Inbound"
      access                     = string                 //"Allow"
      protocol                   = string                 //"Tcp"
      source_port_range          = string                 // "*"
      destination_port_range     = optional(string)       // "*"
      destination_port_ranges    = optional(list(string)) //["9000", "9003", "1438", "1440", "1452"]
      source_address_prefix      = string                 //"*"
      destination_address_prefix = string                 //"*"
      description                = string
    }))
    containers = list(object({
      name        = string
      access_type = string
    }))
    blobs = map(object({
      name           = string,
      container_name = string,
      type           = string
    }))
    task_configuration = list(object({
      name                   = string
      max_concurrent_runs    = number
      quartz_cron_expression = string
      timezone_id            = string
      url                    = string
      task_key               = string
      notebook_path          = string
    }))
    task_configuration_one_off = list(object({
      name                = string
      max_concurrent_runs = number
      timezone_id         = string
      url                 = string
      task_key            = string
      notebook_path       = string
    }))


  })
  default = null
}

variable "powerbi" {
  type = object({
    resource_group = string
    sku_name       = string
    administrators = list(string)
  })
}


variable "nsg_configs" {
  description = "Network security groups configurations"
  type = map(object({
    predefined_rules = list(object({
      name                  = string
      source_address_prefix = optional(string)
    }))
    custom_rules = list(object(
      {
        name                       = string
        priority                   = number
        direction                  = string
        access                     = string
        protocol                   = string
        source_port_range          = string
        source_address_prefix      = optional(string)
        source_address_prefixes    = optional(list(string))
        destination_port_range     = string
        destination_address_prefix = optional(string)
        description                = string
    }))
    }
  ))
}

variable "route_table_routes" {
  description = "list of route table routes"
  type = list(object({
    address_prefix = string
    name           = string
    next_hop_type  = string
  }))
  default = []
}

variable "log_analytics_retention" {
  type        = number
  description = "Log Analytics log retention in days 30 - 730."
  default     = 30
}

variable "apim_certificates" {
  type = map(object({
    encoded_certificate = string
    store_name          = string
  }))

  default = {}
}

variable "static_sta_brands" {
  description = "The static storage account for static websites for each brand"
  type        = list(string)
  default     = []
}
