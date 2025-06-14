data "grafana_folder" "folder" {
  title = "amused-${var.domain}"
}
data "azurerm_subscription" "current" {
}

module "insights_alerts" {
  source          = "../../grafana-alert-rules"
  datasource_uid  = var.datasource_id
  folder_uid      = data.grafana_folder.folder.uid
  rule_group_name = var.app_insights_name
  environment     = var.context.environment
  grafana_metric_alert = {
    dependenciesFailed = {
      subscription      = data.azurerm_subscription.current.subscription_id
      folderuid         = data.grafana_folder.folder.uid
      resourceGroup     = var.resource_group.name
      resourceName      = var.app_insights_name
      metricNamespace   = "microsoft.insights/components"
      alert_name        = "${var.app_insights_name} | App Service Dependency Call Failures > 10"
      alert_summary     = "Critical | ${var.app_insights_name} | App Service Dependency Call Failures > 10"
      alert_description = "${var.app_insights_name} | App Service Dependency Call Failures > 10 "
      no_data_state     = "OK"
      timefor           = "5m"
      interval_seconds  = 240
      domain            = var.domain
      team              = var.team
      severity          = "P2"
      resource_type     = "webapp"
      alert_type        = "Metrics"
      metricName        = "dependencies/failed"
      dimensionFilters  = []
      metric_threshold  = 10
    }

    requestsFailed = {
      subscription      = data.azurerm_subscription.current.subscription_id
      folderuid         = data.grafana_folder.folder.uid
      resourceGroup     = var.resource_group.name
      resourceName      = var.app_insights_name
      metricNamespace   = "microsoft.insights/components"
      alert_name        = "${var.app_insights_name} | App Service Request Failures > 10"
      alert_summary     = "Critical | ${var.app_insights_name} | App Service Request Failures > 10"
      alert_description = "${var.app_insights_name} | App Service Request Failures > 10"
      timefor           = "5m"
      no_data_state     = "OK"
      interval_seconds  = 240
      domain            = var.domain
      team              = var.team
      severity          = "P2"
      resource_type     = "webapp"
      alert_type        = "Metrics"
      metricName        = "requests/failed"
      dimensionFilters  = []
      metric_threshold  = 10
    }
  }
}
