data "grafana_folder" "folder" {
  title = "amused-${var.domain}"
}

data "azurerm_subscription" "current" {
}

###############################################################
# Event Hub Grafana Dashboard
###############################################################

resource "grafana_dashboard" "grafana-eventhub-dashboard" {
  folder = data.grafana_folder.folder.id
  config_json = templatefile("${path.module}/dashboard_templates/grafana-eventhub.json", {
    AzureDataSourceID = var.datasource_id
    DOMAIN            = var.domain
    RESOURCE_GROUP    = var.resource_group.name
    RESOURCE_NAME     = var.eventhub_namespace_name
    SUBSCRIPTION      = data.azurerm_subscription.current.subscription_id
    Dashboard_Name    = "EHN | ${var.eventhub_namespace_name} | Dashboard"
  })
  overwrite = true
}


###############################################################
# Event Hub Grafana Alert Rules
###############################################################

module "eventhub_alerts" {
  source         = "../../grafana-alert-rules"
  environment    = var.context.environment
  datasource_uid = var.datasource_id
  rule_group_name = "EHN | ${var.eventhub_namespace_name}"
  folder_uid     = data.grafana_folder.folder.uid
  grafana_metric_alert = {
    # Size = {
    #   subscription      = data.azurerm_subscription.current.subscription_id
    #   folderuid         = data.grafana_folder.folder.uid
    #   resourceGroup     = var.resource_group.name
    #   resourceName      = var.eventhub_namespace_name
    #   metricNamespace   = "microsoft.eventhub/namespaces"
    #   alert_name        = "${var.eventhub_namespace_name}-Size"
    #   alert_summary     = "EHN | ${var.eventhub_namespace_name} | Size"
    #   alert_description = "Event Hub Size Consumption is High"
    #   timefor           = "5m"
    #   interval_seconds  = 240
    #   domain            = var.domain
    #   team              = var.team
    #   severity          = "P3"
    #   resource_type     = "ehn"
    #   alert_type        = "Metrics"
    #   metricName        = "Size"
    #   aggregation       = "Average"
    #   dimensionFilters  = []
    #   metric_threshold  = 100
    # }

    ThrottledRequests = {
      subscription      = data.azurerm_subscription.current.subscription_id
      folderuid         = data.grafana_folder.folder.uid
      resourceGroup     = var.resource_group.name
      resourceName      = var.eventhub_namespace_name
      metricNamespace   = "microsoft.eventhub/namespaces"
      alert_name        = "${var.eventhub_namespace_name}-ThrottledRequests > 100"
      alert_summary     = "EHN | ${var.eventhub_namespace_name} | ThrottledRequests > 100"
      alert_description = "Event Hub Throttled Requests > 100"
      timefor           = "5m"
      no_data_state     = "OK"
      interval_seconds  = 240
      domain            = var.domain
      team              = var.team
      severity          = "P1"
      resource_type     = "ehn"
      alert_type        = "Metrics"
      metricName        = "ThrottledRequests"
      dimensionFilters  = []
      metric_threshold  = 100
    }

    ServerErrors = {
      subscription      = data.azurerm_subscription.current.subscription_id
      folderuid         = data.grafana_folder.folder.uid
      resourceGroup     = var.resource_group.name
      resourceName      = var.eventhub_namespace_name
      metricNamespace   = "microsoft.eventhub/namespaces"
      alert_name        = "${var.eventhub_namespace_name}-Server Errors > 10"
      alert_summary     = "EHN | ${var.eventhub_namespace_name} | Server Errors > 10"
      alert_description = "Event Hub Server Errors > 10"
      timefor           = "5m"
      no_data_state     = "OK"
      interval_seconds  = 240
      domain            = var.domain
      team              = var.team
      severity          = "P2"
      resource_type     = "ehn"
      alert_type        = "Metrics"
      metricName        = "ServerErrors"
      dimensionFilters  = []
      metric_threshold  = 10
    }

    UserErrors = {
      subscription      = data.azurerm_subscription.current.subscription_id
      folderuid         = data.grafana_folder.folder.uid
      resourceGroup     = var.resource_group.name
      resourceName      = var.eventhub_namespace_name
      metricNamespace   = "microsoft.eventhub/namespaces"
      alert_name        = "${var.eventhub_namespace_name}-User Errors"
      alert_summary     = "EHN | ${var.eventhub_namespace_name} | User Errors"
      alert_description = "Event Hub User Errors are High"
      timefor           = "5m"
      interval_seconds  = 240
      domain            = var.domain
      team              = var.team
      severity          = "P2"
      resource_type     = "ehn"
      alert_type        = "Metrics"
      metricName        = "UserErrors"
      dimensionFilters  = []
      metric_threshold  = 10
    }
  }
}
