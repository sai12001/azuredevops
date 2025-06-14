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
    condition     = contains(["account", "racing", "bet", "promotion", "sport", "infra", "whatever", "core", "console", "utilities"], var.with_solution_configs.domain_name)
    error_message = "Domain name must be one of following: account, racing, bet, promotion, sport, infra, core, console, utilities.[Case Sensitive]"
  }
  validation {
    condition     = length(var.with_solution_configs.team_name) < 24
    error_message = "Team name should not be more than 24 characters"
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
    health_check_path    = optional(string)
    sub_domain           = optional(string)
    required_custom_dns = optional(object({
      sub_domain = string
    }))
    plain_text_settings = map(string)
    secure_settings = list(object({
      domain      = string
      secret_name = string
      config_name = string
    }))
    connection_strings = optional(list(object({
      domain      = string
      config_name = string
      type        = string
      secret_name = string
    })))
  }))

  validation {
    condition     = alltrue([for app in var.with_apps_configs : contains(["webapp", "fnapp"], coalesce(app.app_type, "fnapp"))])
    error_message = "App type only support fnapp and webapp"
  }
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

variable "needs_eventhubs" {
  description = "Create eventhubs in this domain for in domain/out domain usage"
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

variable "needs_consumer_groups" {
  description = "Create eventhubs consumer groups across domains"
  type = list(object({
    domain_name   = string
    eventhub_name = string
    name          = string
    user_metadata = optional(string)
  }))
  default = []
}
variable "needs_eh_auth_rules" {
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

variable "needs_servicebus_queues" {
  description = "TODO"
  type = list(object({
    domain_name                             = string
    name                                    = string
    enable_partitioning                     = optional(bool)
    max_delivery_count                      = optional(number)
    requires_session                        = optional(bool)
    requires_duplicate_detection            = optional(bool)
    duplicate_detection_history_time_window = optional(string)
    default_message_ttl                     = optional(string)
    auth_rules = optional(list(object({
      name   = string
      listen = optional(bool)
      send   = optional(bool)
      manage = optional(bool)
    })))
  }))
  default = []
}

variable "needs_servicebus_queue_auth_rules" {
  description = "TODO"
  type = list(object({
    domain_name = string
    queue_name  = string
    name        = string
    listen      = optional(bool)
    send        = optional(bool)
    manage      = optional(bool)
  }))
  default = []
}


variable "needs_servicebus_topics" {
  description = "TODO"
  type = list(object({
    domain_name         = string
    name                = string
    enable_partitioning = optional(bool)
    auth_rules = optional(list(object({
      name   = string
      listen = optional(bool)
      send   = optional(bool)
      manage = optional(bool)
    })))
  }))
  default = []
}

variable "needs_servicebus_topic_auth_rules" {
  description = "TODO"
  type = list(object({
    domain_name = string
    topic_name  = string
    name        = string
    listen      = optional(bool)
    send        = optional(bool)
    manage      = optional(bool)
  }))
  default = []
}

variable "needs_servicebus_topic_subscriptions" {
  description = "TODO"
  type = list(object({
    domain_name                             = string
    topic_name                              = string
    name                                    = string
    max_delivery_count                      = optional(number)
    forward_to_queue                        = optional(string)
    forward_dead_lettered_messages_to_queue = optional(string)
    enable_batched_operations               = optional(bool)
    requires_session                        = optional(bool)
    sql_filter = optional(object({
      name          = string
      filter_string = string
    }))
    correlation_filter = optional(object({
      name                = string
      content_type        = optional(string)
      correlation_id      = optional(string)
      label               = optional(string)
      message_id          = optional(string)
      reply_to            = optional(string)
      reply_to_session_id = optional(string)
      session_id          = optional(string)
      to                  = optional(string)
      properties          = map(string)
    }))
  }))
  default = []
}

variable "needs_storage_accounts" {
  description = "configure the storage accounts required for this solution"
  type = list(object({
    name                     = string
    account_tier             = optional(string)
    account_replication_type = optional(string)
    containers = optional(list(object({
      name        = string
      access_type = string
    })))
    tables = optional(list(object({
      name = string
    })))
    queues = optional(list(object({
      name = string
    })))
    cors_allowed_origins = optional(list(object({
      allowed_origins   = list(string)
      allowed_methods   = list(string)
      max_age_InSeconds = optional(number)
    })))
  }))
  default = []
}

variable "needs_postgresql_databases" {
  description = "Configuration for postgres sql databases in domain server"
  type = list(object({
    name      = string
    domain    = string
    charset   = optional(string)
    collation = optional(string)
  }))
  default = []
}

variable "extra_subnet_access" {
  description = "TODO"
  type        = list(string)
  default     = ["subnet-apim"]

}

variable "enable_grafana" {
  description = "The flag to tell do we need grafana integration or not"
  type        = bool
  default     = true
}

variable "grafana-ai-log-based-alerts" {
  type = object({
    alerts = list(object({
      alert_name        = string
      alert_summary     = string
      alert_description = string
      team              = string
      severity          = string
      no_data_state     = optional(string)
      query             = string
    }))
    interval_seconds = number
    timefor          = string
  })

  default = {
    alerts           = []
    interval_seconds = 1
    timefor          = "value"
  }
  description = "Grafana AI Logs Based Alert"
}
