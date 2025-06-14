locals {
  tags                  = merge(var.resource_group.tags, var.tags)
  domain_name           = var.domain
  app_service_plan_name = "${var.context.environment}-asp-${var.context.product}-${var.domain}-${var.app_service_plan_name}-${var.context.location_abbr}"
  log_workspace = {
    name                = "${var.context.environment}-logs-${var.context.product}-workspace-${var.context.location_abbr}"
    resource_group_name = "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
  }
}

data "azurerm_log_analytics_workspace" "law" {
  name                = local.log_workspace.name
  resource_group_name = local.log_workspace.resource_group_name
}

resource "azurerm_service_plan" "app_service_plan" {
  name                     = local.app_service_plan_name
  location                 = var.resource_group.location
  resource_group_name      = var.resource_group.name
  tags                     = local.tags
  per_site_scaling_enabled = var.per_site_scaling
  sku_name                 = var.sku_name
  os_type                  = "Linux"

  lifecycle {
    ignore_changes = [sku_name]
  }
}

#----------------------------------------------------------------------------------------------------------
# ASP Diagnostic Setting
#----------------------------------------------------------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "app_service_plan_diags" {
  name                           = format("%s-diags", azurerm_service_plan.app_service_plan.name)
  target_resource_id             = azurerm_service_plan.app_service_plan.id
  log_analytics_workspace_id     = data.azurerm_log_analytics_workspace.law.id

metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }
  
  }
  lifecycle {
    ignore_changes = [metric, log_analytics_workspace_id]
  }
  depends_on = [
    azurerm_service_plan.app_service_plan
  ]
}