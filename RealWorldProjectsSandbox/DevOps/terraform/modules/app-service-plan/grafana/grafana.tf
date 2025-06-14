locals {
  app_service_plan_name = "${var.context.environment}-asp-${var.context.product}-${var.domain}-${var.app_service_plan_name}-${var.context.location_abbr}"
}
data "grafana_folder" "folder" {
  title = "amused-${var.domain}"
}

data "azurerm_subscription" "current" {
}

###############################################################
# App Service Plan Alert Rules
###############################################################
module "asp_alerts" {
  source          = "../../grafana-alert-rules"
  datasource_uid  = var.datasource_id
  folder_uid      = data.grafana_folder.folder.uid
  rule_group_name = "ASP | ${local.app_service_plan_name}"
  environment     = var.context.environment
  grafana_metric_alert = {
    CpuPercentage = {
      subscription      = data.azurerm_subscription.current.subscription_id
      folderuid         = data.grafana_folder.folder.uid
      resourceGroup     = var.resource_group.name
      resourceName      = local.app_service_plan_name
      metricNamespace   = "microsoft.web/serverfarms"
      alert_name        = "ASP | ${local.app_service_plan_name} | High CPU Usage > 75%"
      alert_summary     = "ASP | ${local.app_service_plan_name} | High CPU Usage > 75%"
      alert_description = "App Service Plan CPU Usage > 75%"
      timefor           = "5m"
      interval_seconds  = 240
      domain            = var.domain
      team              = var.team
      severity          = "P1"
      resource_type     = "asp"
      alert_type        = "Metrics"
      aggregation       = "Average"
      metricName        = "CpuPercentage"
      dimensionFilters  = []
      metric_threshold  = 75
    }
    MemoryPercentage = {
      subscription      = data.azurerm_subscription.current.subscription_id
      folderuid         = data.grafana_folder.folder.uid
      resourceGroup     = var.resource_group.name
      resourceName      = local.app_service_plan_name
      metricNamespace   = "microsoft.web/serverfarms"
      alert_name        = "ASP | ${local.app_service_plan_name} | High Memory Usage > 75%"
      alert_summary     = "ASP | ${local.app_service_plan_name} | High Memory Usage > 75%"
      alert_description = "App Service Plan Memory Usage is High > 75%"
      timefor           = "5m"
      interval_seconds  = 240
      domain            = var.domain
      team              = var.team
      severity          = "P1"
      resource_type     = "asp"
      alert_type        = "Metrics"
      aggregation       = "Average"
      metricName        = "MemoryPercentage"
      dimensionFilters  = []
      metric_threshold  = 75
    }
  }
}
