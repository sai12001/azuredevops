locals {
  domain_name = var.domain 
  tags = merge(var.resource_group.tags, var.tags)
  app_insights_diagnostic_log_categories = ["AppExceptions","AppEvents"]
}

data "azurerm_log_analytics_workspace" "workspace" {
  name                = var.log_workspace.name
  resource_group_name = var.log_workspace.resource_group_name
}

resource "azurerm_application_insights" "app_insights" {
  name                = var.application_insights_name
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  workspace_id        = data.azurerm_log_analytics_workspace.workspace.id
  application_type    = var.application_type
  tags                = local.tags
}
#----------------------------------------------------------------------------------------------------------
#App Insights Diagnostic Setting
#----------------------------------------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "app_insights_diags" {
  name                       = format("%s-diags", azurerm_application_insights.app_insights.name)
  target_resource_id         = azurerm_application_insights.app_insights.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.workspace.id
  dynamic "log" {
     for_each = local.app_insights_diagnostic_log_categories
    content {
      category = log.value
      retention_policy {
         enabled = false
       }
     }
   }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }

  }
  lifecycle {
    ignore_changes = [log, log_analytics_workspace_id]
  }
  depends_on = [
    azurerm_application_insights.app_insights
  ]
}
