locals {
  automation_account_name = "${var.context.environment}-aa-${var.context.product}-infra-shared-${var.context.location_abbr}"  
  log_workspace           = {
    name                  = "${var.context.environment}-logs-${var.context.product}-workspace-${var.context.location_abbr}"
    resource_group_name   = "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
  }
  automation_account_diagnostic_log_categories = ["JobLogs"]
}
#----------------------------------------------------------------------------------------------------------
#Data sources
#----------------------------------------------------------------------------------------------------------
data "azurerm_client_config" "current" {}

data "azurerm_log_analytics_workspace" "law" {
  name                = local.log_workspace.name
  resource_group_name = local.log_workspace.resource_group_name
}
#----------------------------------------------------------------------------------------------------------
#Automation Account
#----------------------------------------------------------------------------------------------------------
resource "azurerm_automation_account" "automation_account" {
  name                                  = local.automation_account_name
  location                              = var.resource_group.location
  resource_group_name                   = var.resource_group.name
  sku_name                              = "Basic"
  
  identity {
    type                                = "SystemAssigned"
  }
}
#----------------------------------------------------------------------------------------------------------
#Automation Account Diagnostic Settings
#----------------------------------------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "automation_account_diags" {
  name                                    = format("%s-diags", azurerm_automation_account.automation_account.name)
  target_resource_id                      = azurerm_automation_account.automation_account.id
  log_analytics_workspace_id              = data.azurerm_log_analytics_workspace.law.id
/*----------------------------------------------------------------------------------------------------------
Log types to enable:
- JobLogs
- JobStreams
- DscNodeStatus
----------------------------------------------------------------------------------------------------------*/

  dynamic "log" {
    for_each = local.automation_account_diagnostic_log_categories
    content {
      category = log.value
      retention_policy {
        days    = var.log_analytics_retention
        enabled = true
      }
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      days    = var.log_analytics_retention
      enabled = true
    }
  }

  depends_on = [azurerm_automation_account.automation_account]
}
#----------------------------------------------------------------------------------------------------------
#Resource Lock
#----------------------------------------------------------------------------------------------------------
resource "azurerm_management_lock" "automation_account_lock" {
  name                                  = format("%s-lck", azurerm_automation_account.automation_account.name)
  scope                                 = azurerm_automation_account.automation_account.id
  lock_level                            = "CanNotDelete"
  notes                                 = "Resource Lock - Can Not Delete" 

  depends_on = [azurerm_automation_account.automation_account]
}