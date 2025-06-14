locals {
  folder_name = "amused-${var.domain_name}"
  servicebus_namespace_name          = "${var.context.environment}-sb-${var.context.product}-infra-shared-${var.context.location_abbr}"
  
}

data "grafana_folder" "folder" {
  title = local.folder_name
}


data "azurerm_subscription" "current" {
}

resource "grafana_dashboard" "grafana_servicebus_dashboard" {
  folder = data.grafana_folder.folder.id
  config_json = templatefile("${path.module}/dashboard_templates/grafana-service-bus.json", {
    AzureDataSourceID = var.datasource_id
    RESOURCE_GROUP    = "${var.context.environment}-rg-ng-infra-shared-eau"
    RESOURCE_NAME     = "${var.context.environment}-sb-ng-infra-shared-eau"
    SUBSCRIPTION      = data.azurerm_subscription.current.subscription_id
  })
  overwrite = true
}


module "servicebus_alerts" {
  source         = "../../grafana-alert-rules"
  datasource_uid = var.datasource_id
  folder_uid     = data.grafana_folder.folder.uid
  environment    = var.context.environment
  rule_group_name = "SB | ${local.servicebus_namespace_name}"
  grafana_metric_alert = {
    ServerErrors = {
      subscription      = data.azurerm_subscription.current.subscription_id
      folderuid         = data.grafana_folder.folder.uid
      resourceGroup     = "${var.context.environment}-rg-ng-infra-shared-eau"
      resourceName      = "${var.context.environment}-sb-ng-infra-shared-eau"
      metricNamespace   = "microsoft.servicebus/namespaces"
      alert_name        = "Service Bus Server Errors > 10"
      alert_summary     = "Critical | Service Bus Server Errors > 10"
      alert_description = "Service Bus Server Errors > 10"
      timefor           = "5m"
      interval_seconds  = 240
      domain            = "infra"
      team              = "cloudops"
      severity          = "P2"
      resource_type     = "sb"
      alert_type        = "Metrics"
      metricName        = "ServerErrors"
      dimensionFilters  = []
      metric_threshold  = 10
    }

    UserErrors = {
      subscription      = data.azurerm_subscription.current.subscription_id
      folderuid         = data.grafana_folder.folder.uid
      resourceGroup     = "${var.context.environment}-rg-ng-infra-shared-eau"
      resourceName      = "${var.context.environment}-sb-ng-infra-shared-eau"
      metricNamespace   = "microsoft.servicebus/namespaces"
      alert_name        = "Service Bus User Errors > 10"
      alert_summary     = "Critical | Service Bus User Errors > 10"
      alert_description = "Service Bus User Errors > 10"
      timefor           = "5m"
      interval_seconds  = 240
      domain            = "infra"
      team              = "cloudops"
      severity          = "P2"
      resource_type     = "sb"
      alert_type        = "Metrics"
      metricName        = "UserErrors"
      dimensionFilters  = []
      metric_threshold  = 10
    }

    ThrottledRequests = {
      subscription      = data.azurerm_subscription.current.subscription_id
      folderuid         = data.grafana_folder.folder.uid
      resourceGroup     = "${var.context.environment}-rg-ng-infra-shared-eau"
      resourceName      = "${var.context.environment}-sb-ng-infra-shared-eau"
      metricNamespace   = "microsoft.servicebus/namespaces"
      alert_name        = "Service Bus Throttled Requests > 10"
      alert_summary     = "Critical | Service Bus Throttled Requests > 10"
      alert_description = "Service Bus Throttled Requests > 10"
      timefor           = "5m"
      interval_seconds  = 240
      domain            = "infra"
      team              = "cloudops"
      severity          = "P1"
      resource_type     = "sb"
      alert_type        = "Metrics"
      metricName        = "ThrottledRequests"
      dimensionFilters  = []
      metric_threshold  = 10
    }
  }
}
