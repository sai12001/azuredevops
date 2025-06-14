
locals {
  cosmos_db_account_name = "${var.context.environment}-docdb-${var.context.product}-${var.cosmos_name}-${var.context.location_abbr}"
}
data "grafana_folder" "folder" {
  title = "amused-${var.domain}"
}

data "azurerm_subscription" "current" {
}

###############################################################
# Cosmos DB Alert Rules
###############################################################

module "cosmosdb_alerts" {
  source          = "../../grafana-alert-rules"
  datasource_uid  = var.datasource_id
  environment     = var.context.environment
  rule_group_name = "CosmosDB | ${local.cosmos_db_account_name}"
  folder_uid      = data.grafana_folder.folder.uid
  grafana_metric_alert = {
    NormalizedRUConsumption = {
      subscription      = data.azurerm_subscription.current.subscription_id
      folderuid         = data.grafana_folder.folder.uid
      resourceGroup     = var.resource_group.name
      resourceName      = local.cosmos_db_account_name
      metricNamespace   = "microsoft.documentdb/databaseaccounts"
      alert_name        = "DocDB | ${local.cosmos_db_account_name} | RU"
      alert_summary     = "Critical | CosmosDB Normalized RU Consumption > 75%"
      alert_description = "CosmosDB Normalized RU Consumption > 75%"
      timefor           = "5m"
      interval_seconds  = 240
      domain            = var.domain
      team              = "account"
      severity          = "P2"
      resource_type     = "docdb"
      alert_type        = "Metrics"
      metricName        = "NormalizedRUConsumption"
      aggregation       = "Average"
      dimensionFilters  = []
      metric_threshold  = 75
    }

    request_errors = {
      subscription      = data.azurerm_subscription.current.subscription_id
      folderuid         = data.grafana_folder.folder.uid
      resourceGroup     = var.resource_group.name
      resourceName      = local.cosmos_db_account_name
      metricNamespace   = "microsoft.documentdb/databaseaccounts"
      alert_name        = "DocDB | ${local.cosmos_db_account_name} | 4xx Errors"
      alert_summary     = "Critical | CosmosDB 4xx Errors >10"
      alert_description = "CosmosDB 4xx errors >10 "
      timefor           = "5m"
      interval_seconds  = 240
      domain            = var.domain
      no_data_state     = "OK"
      team              = "account"
      severity          = "P2"
      resource_type     = "docdb"
      alert_type        = "Metrics"
      metricName        = "TotalRequests"
      dimensionFilters = [{
        "dimension" = "StatusCode"
        "filters"   = ["4"]
        "operator"  = "sw"
      }]
      metric_threshold = 10
    }

    ServerSideLatency = {
      subscription      = data.azurerm_subscription.current.subscription_id
      folderuid         = data.grafana_folder.folder.uid
      resourceGroup     = var.resource_group.name
      resourceName      = local.cosmos_db_account_name
      metricNamespace   = "microsoft.documentdb/databaseaccounts"
      alert_name        = "DocDB | ${local.cosmos_db_account_name} | Latency"
      alert_summary     = "Critical | CosmosDB ServerSideLatency > 100ms"
      alert_description = "CosmosDB ServerSideLatency > 100 ms"
      timefor           = "5m"
      interval_seconds  = 240
      domain            = var.domain
      team              = "account"
      severity          = "P1"
      resource_type     = "docdb"
      alert_type        = "Metrics"
      aggregation       = "Average"
      metricName        = "ServerSideLatency"
      metric_threshold  = 100
      dimensionFilters  = []
    }
  }
}

