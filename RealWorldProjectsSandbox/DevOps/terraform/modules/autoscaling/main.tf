locals {
  domain_name = var.domain
  tags        = merge(var.resource_group.tags, var.tags)
}

resource "azurerm_monitor_autoscale_setting" "autoscale_setting" {
  count = var.enable_autoscaling == true ? 1 : 0
  name                = var.autoscale_name
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  target_resource_id  = var.resource_id
  tags                = local.tags
  profile {
    name = var.profile_name

    capacity {
      default = 1
      minimum = 1
      maximum = var.profile_capacity_maximum
    }

    dynamic "rule" {
      for_each = contains(var.rulelist, "Memory") ? [1] : []
      content {
        metric_trigger {
          metric_name        = "MemoryPercentage"
          metric_resource_id = var.resource_id
          time_grain         = "PT1M"
          statistic          = "Average"
          time_window        = "PT5M"
          time_aggregation   = "Average"
          operator           = "GreaterThan"
          threshold          = 80
          metric_namespace   = "Microsoft.Web/serverfarms"
        }

        scale_action {
          direction = "Increase"
          type      = "ChangeCount"
          value     = 1
          cooldown  = "PT1M"
        }
      }
    }

    dynamic "rule" {
      for_each = contains(var.rulelist, "Memory") ? [1] : []
      content {
        metric_trigger {
          metric_name        = "MemoryPercentage"
          metric_resource_id = var.resource_id
          time_grain         = "PT1M"
          statistic          = "Average"
          time_window        = "PT5M"
          time_aggregation   = "Average"
          operator           = "LessThan"
          threshold          = 50
          metric_namespace   = "Microsoft.Web/serverfarms"
        }

        scale_action {
          direction = "Decrease"
          type      = "ChangeCount"
          value     = 1
          cooldown  = "PT1M"
        }
      }
    }

    dynamic "rule" {
      for_each = contains(var.rulelist, "CPU") ? [1] : []
      content {
        metric_trigger {
          metric_name        = "CPUPercentage"
          metric_resource_id = var.resource_id
          time_grain         = "PT1M"
          statistic          = "Average"
          time_window        = "PT5M"
          time_aggregation   = "Average"
          operator           = "GreaterThan"
          threshold          = 75
          metric_namespace   = "Microsoft.Web/serverfarms"
        }

        scale_action {
          direction = "Increase"
          type      = "ChangeCount"
          value     = 1
          cooldown  = "PT1M"
        }
      }
    }

    dynamic "rule" {
      for_each = contains(var.rulelist, "CPU") ? [1] : []
      content {
        metric_trigger {
          metric_name        = "CPUPercentage"
          metric_resource_id = var.resource_id
          time_grain         = "PT1M"
          statistic          = "Average"
          time_window        = "PT5M"
          time_aggregation   = "Average"
          operator           = "LessThan"
          threshold          = 50
          metric_namespace   = "Microsoft.Web/serverfarms"
        }

        scale_action {
          direction = "Decrease"
          type      = "ChangeCount"
          value     = 1
          cooldown  = "PT1M"
        }
      }
    }

    dynamic "rule" {
      for_each = contains(var.rulelist, "Data In") ? [1] : []
      content {
        metric_trigger {
          metric_name        = "DataIn"
          metric_resource_id = var.resource_id
          time_grain         = "PT1M"
          statistic          = "Average"
          time_window        = "PT5M"
          time_aggregation   = "Average"
          operator           = "GreaterThan"
          threshold          = 75
          metric_namespace   = "Microsoft.Web/serverfarms"
        }

        scale_action {
          direction = "Increase"
          type      = "ChangeCount"
          value     = 1
          cooldown  = "PT1M"
        }
      }
    }

    dynamic "rule" {
      for_each = contains(var.rulelist, "Data In") ? [1] : []
      content {
        metric_trigger {
          metric_name        = "DataIn"
          metric_resource_id = var.resource_id
          time_grain         = "PT1M"
          statistic          = "Average"
          time_window        = "PT5M"
          time_aggregation   = "Average"
          operator           = "LessThan"
          threshold          = 50
          metric_namespace   = "Microsoft.Web/serverfarms"
        }

        scale_action {
          direction = "Decrease"
          type      = "ChangeCount"
          value     = 1
          cooldown  = "PT1M"
        }
      }
    }

    dynamic "rule" {
      for_each = contains(var.rulelist, "Data Out") ? [1] : []
      content {
        metric_trigger {
          metric_name        = "DataOut"
          metric_resource_id = var.resource_id
          time_grain         = "PT1M"
          statistic          = "Average"
          time_window        = "PT5M"
          time_aggregation   = "Average"
          operator           = "GreaterThan"
          threshold          = 75
          metric_namespace   = "Microsoft.Web/serverfarms"
        }

        scale_action {
          direction = "Increase"
          type      = "ChangeCount"
          value     = 1
          cooldown  = "PT1M"
        }
      }
    }

    dynamic "rule" {
      for_each = contains(var.rulelist, "Data Out") ? [1] : []
      content {
        metric_trigger {
          metric_name        = "DataOut"
          metric_resource_id = var.resource_id
          time_grain         = "PT1M"
          statistic          = "Average"
          time_window        = "PT5M"
          time_aggregation   = "Average"
          operator           = "LessThan"
          threshold          = 50
          metric_namespace   = "Microsoft.Web/serverfarms"
        }

        scale_action {
          direction = "Decrease"
          type      = "ChangeCount"
          value     = 1
          cooldown  = "PT1M"
        }
      }
    }

  }

  dynamic "notification" {
    for_each = var.enable_notification == true ? [1] : []
    content {
      email {
        send_to_subscription_administrator    = var.email_send_to_admin
        send_to_subscription_co_administrator = var.email_send_to_co_admin
        custom_emails                         = var.email_custom_emails
      }
    }
  }
}






