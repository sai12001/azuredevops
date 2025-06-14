data "grafana_folder" "folder" {
  title = "amused-${var.domain}"
}

data "azurerm_subscription" "current" {
}




module "signalr_alerts" {
  source          = "../../grafana-alert-rules"
  datasource_uid  = var.datasource_id
  environment     = var.context.environment
  folder_uid      = data.grafana_folder.folder.uid
  rule_group_name = "SignalR | ${var.context.environment}-sigr-ng-infra"
  grafana_metric_alert = {
    ServerLoad = {
      subscription      = data.azurerm_subscription.current.subscription_id
      folderuid         = data.grafana_folder.folder.uid
      resourceGroup     = "${var.context.environment}-rg-ng-infra-shared-eau"
      resourceName      = "${var.context.environment}-sigr-ng-infra"
      metricNamespace   = "microsoft.signalrservice/signalr"
      alert_name        = "SignalR Server Load > 75%"
      alert_summary     = "Critical | SignalR High Server Load > 75%"
      alert_description = "SignalR Server Load > 75%"
      timefor           = "5m"
      interval_seconds  = 240
      domain            = "infra"
      team              = "cloudops"
      severity          = "P2"
      resource_type     = "signalr"
      alert_type        = "Metrics"
      aggregation       = "Average"
      metricName        = "ServerLoad"
      dimensionFilters  = []
      metric_threshold  = 75
    }

    ConnectionQuotaUtilization = {
      subscription      = data.azurerm_subscription.current.subscription_id
      folderuid         = data.grafana_folder.folder.uid
      resourceGroup     = "${var.context.environment}-rg-ng-infra-shared-eau"
      resourceName      = "${var.context.environment}-sigr-ng-infra"
      metricNamespace   = "microsoft.signalrservice/signalr"
      alert_name        = "SignalR Connection Quota Utilization > 75%"
      alert_summary     = "Critical | SignalR Connection Quota Utilization > 75%"
      alert_description = "SignalR Connection Quota Utilization > 75%"
      timefor           = "5m"
      interval_seconds  = 240
      domain            = var.domain
      team              = "cloudops"
      severity          = "P2"
      resource_type     = "signalr"
      alert_type        = "Metrics"
      aggregation       = "Average"
      metricName        = "ConnectionQuotaUtilization"
      dimensionFilters  = []
      metric_threshold  = 75
    }

    UserErrors = {
      subscription      = data.azurerm_subscription.current.subscription_id
      folderuid         = data.grafana_folder.folder.uid
      resourceGroup     = "${var.context.environment}-rg-ng-infra-shared-eau"
      resourceName      = "${var.context.environment}-sigr-ng-infra"
      metricNamespace   = "microsoft.signalrservice/signalr"
      alert_name        = "SignalR User Errors > 3%"
      alert_summary     = "Critical | SignalR High User Errors > 3%"
      alert_description = "SignalR User Errors > 3%"
      timefor           = "5m"
      interval_seconds  = 240
      domain            = "infra"
      team              = "cloudops"
      severity          = "P2"
      resource_type     = "signalr"
      alert_type        = "Metrics"
      metricName        = "UserErrors"
      aggregation       = "Average"
      dimensionFilters  = []
      metric_threshold  = 3
    }

    SystemErrors = {
      subscription      = data.azurerm_subscription.current.subscription_id
      folderuid         = data.grafana_folder.folder.uid
      resourceGroup     = "${var.context.environment}-rg-ng-infra-shared-eau"
      resourceName      = "${var.context.environment}-sigr-ng-infra"
      metricNamespace   = "microsoft.signalrservice/signalr"
      alert_name        = "SignalR System Errors > 3%"
      alert_summary     = "Critical | SignalR High System Errors > 3%"
      alert_description = "SignalR System Errors > 3%"
      timefor           = "5m"
      interval_seconds  = 240
      domain            = "infra"
      team              = "cloudops"
      severity          = "P1"
      resource_type     = "signalr"
      alert_type        = "Metrics"
      aggregation       = "Average"
      metricName        = "SystemErrors"
      dimensionFilters  = []
      metric_threshold  = 3
    }

  }
}

resource "grafana_dashboard" "signalr_dashboard" {
  folder = data.grafana_folder.folder.id
  config_json = templatefile("${path.module}/dashboard_templates/signalr.json", {
    uid               = "iZqD4b4Vz"
    AzureDataSourceID = var.datasource_id
    RESOURCE_GROUP    = "${var.context.environment}-rg-ng-infra-shared-eau"
    RESOURCE_NAME     = "${var.context.environment}-sigr-ng-infra"
    SUBSCRIPTION      = data.azurerm_subscription.current.subscription_id
  })
  overwrite = true
}
