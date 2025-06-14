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
variable "servicebus_namespace_auth_rules" {
  description = "Namespace Auth Rules at domain level"
  type        = list(string)
  default     = []
}

variable "servicebus_namespace" {
  description = "TODO"
  type = object({
    sku            = optional(string)
    capacity       = optional(number)
    zone_redundant = optional(bool)
  })
  default = null
}

variable "servicebus_queues" {
  description = "TODO"
  type = list(object({
    domain_name                             = string
    name                                    = string
    enable_partitioning                     = optional(bool)
    max_delivery_count                      = optional(number)
    requires_session                        = optional(bool)
    default_message_ttl                     = optional(string)
    requires_duplicate_detection            = optional(bool)
    duplicate_detection_history_time_window = optional(string)
    auth_rules = optional(list(object({
      name   = string
      listen = optional(bool)
      send   = optional(bool)
      manage = optional(bool)
    })))
  }))
  default = []
}

variable "servicebus_queue_auth_rules" {
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


variable "servicebus_topics" {
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

variable "servicebus_topic_auth_rules" {
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

variable "servicebus_topic_subscriptions" {
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

variable "tags" {
  description = "Tags need to attach to this resource"
  type        = map(string)
  default     = {}
}

variable "log_analytics_retention" {
  description = "Rentention days for log analytics"
  type        = number
  default     = 30
}

variable "datasource_id" {
  description = "Grafana Datasource ID"
  type        = string
  default     = ""
}
