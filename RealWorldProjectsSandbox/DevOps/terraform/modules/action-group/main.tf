locals {
  domain_name = var.domain
  # tags         = merge(var.resource_group.tags, var.tags)

  action_groups = defaults(var.action_groups, {
    enable_email_receiver              = true
    enable_sms_receiver                = false
    enable_voice_receiver              = false
    enable_automation_runbook_receiver = false
    enable_azure_function_receiver     = false
    enable_event_hub_receiver          = false
    enable_logic_app_receiver          = false
    enable_webhook_receiver            = false
  })


}

resource "azurerm_monitor_action_group" "action_group" {
  for_each            = local.action_groups
  name                = "${var.context.environment}-ag-${var.context.product}-${each.value.ag_short_name}"
  resource_group_name = var.resource_group.name
  short_name          = each.value.ag_short_name

  dynamic "email_receiver" {
    for_each = each.value.enable_email_receiver ? [1] : []
    content {
      name          = each.value.email.email_name
      email_address = each.value.email.email_address
    }
  }

  dynamic "sms_receiver" {
    for_each = each.value.enable_sms_receiver ? [1] : []
    content {
      name         = each.value.sms.sms_name
      country_code = "61"
      phone_number = each.value.sms.sms_phone_number
    }
  }

  dynamic "voice_receiver" {
    for_each = each.value.enable_voice_receiver ? [1] : []
    content {
      name         = each.value.voice.voice_name
      country_code = "61"
      phone_number = each.value.voice.voice_phone_number
    }
  }


  dynamic "automation_runbook_receiver" {
    for_each = each.value.enable_automation_runbook_receiver ? [1] : []
    content {
      name                    = each.value.automation_runbook.name
      automation_account_id   = each.value.automation_runbook.automation_account_id
      runbook_name            = each.value.automation_runbook.runbook_name
      webhook_resource_id     = each.value.automation_runbook.webhook_resource_id
      is_global_runbook       = each.value.automation_runbook.is_global_runbook
      service_uri             = each.value.automation_runbook.service_uri
      use_common_alert_schema = each.value.automation_runbook.use_common_alert_schema
    }
  }

  dynamic "azure_function_receiver" {
    for_each = each.value.enable_azure_function_receiver ? [1] : []
    content {
      name                     = each.value.azure_function_receiver.name
      function_app_resource_id = each.value.azure_function_receiver.function_app_resource_id
      function_name            = each.value.azure_function_receiver.function_name
      http_trigger_url         = each.value.azure_function_receiver.http_trigger_url
      use_common_alert_schema  = each.value.azure_function_receiver.use_common_alert_schema
    }
  }

  dynamic "event_hub_receiver" {
    for_each = each.value.enable_event_hub_receiver ? [1] : []
    content {
      name                    = each.value.event_hub_receiver.name
      event_hub_id            = each.value.event_hub_receiver.event_hub_id
      use_common_alert_schema = each.value.event_hub_receiver.use_common_alert_schema
    }
  }

  dynamic "logic_app_receiver" {
    for_each = each.value.enable_logic_app_receiver ? [1] : []
    content {
      name                    = each.value.logic_app_receiver.name
      resource_id             = each.value.logic_app_receiver.resource_id
      callback_url            = each.value.logic_app_receiver.callback_url
      use_common_alert_schema = each.value.logic_app_receiver.use_common_alert_schema
    }
  }

  dynamic "webhook_receiver" {
    for_each = each.value.enable_webhook_receiver ? [1] : []
    content {
      name                    = each.value.webhook_receiver.name
      service_uri             = each.value.webhook_receiver.service_uri
      use_common_alert_schema = each.value.webhook_receiver.use_common_alert_schema
    }
  }

}

