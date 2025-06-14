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
    tags          = optional(map(string))
    location      = optional(string)
    location_abbr = optional(string)
  })
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
