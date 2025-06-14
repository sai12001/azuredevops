data "grafana_folder" "folder" {
  title = "amused-${var.domain}"
}

data "azurerm_subscription" "current" {
}

resource "grafana_dashboard" "postgres_dashboard" {
  folder = data.grafana_folder.folder.id
  config_json = templatefile("${path.module}/dashboard_templates/grafana-postgres.json", {
    AzureDataSourceID = var.datasource_id
    DOMAIN            = var.domain
    RESOURCE_GROUP    = var.resource_group.name
    RESOURCE_NAME     = var.psql_server_name
    SUBSCRIPTION_ID   = data.azurerm_subscription.current.subscription_id
    Dashboard_Name    = "PSQL | ${var.psql_server_name}"
  })
  overwrite = true
}


###############################################################
# Postgres Alert Rules
###############################################################

module "psql_alerts" {
  source         = "../../../grafana-alert-rules"
  datasource_uid = var.datasource_id
  folder_uid     = data.grafana_folder.folder.uid
  environment    = var.context.environment
  rule_group_name = "PSQL | ${var.psql_server_name}"
  grafana_metric_alert = {
    connections_failed = {
      subscription      = data.azurerm_subscription.current.subscription_id
      folderuid         = data.grafana_folder.folder.uid
      resourceGroup     = var.resource_group.name
      resourceName      = var.psql_server_name
      metricNamespace   = "microsoft.dbforpostgresql/flexibleservers"
      alert_name        = "PSQL | Postgres Failed Connection > 10"
      alert_summary     = "Critical | Postgres High Failed Connection > 10"
      alert_description = "Postgres Failed 4xx Connection > 10"
      timefor           = "5m"
      interval_seconds  = 240
      domain            = var.domain
      team              = var.team
      severity          = "P1"
      resource_type     = "psql"
      alert_type        = "Metrics"
      no_data_state     = "OK"
      metricName        = "connections_failed"
      dimensionFilters  = []
      metric_threshold  = 10
    }

    cpu_percent = {
      subscription      = data.azurerm_subscription.current.subscription_id
      folderuid         = data.grafana_folder.folder.uid
      resourceGroup     = var.resource_group.name
      resourceName      = var.psql_server_name
      metricNamespace   = "microsoft.dbforpostgresql/flexibleservers"
      alert_name        = "PSQL| Postgres CPU Percentage > 75%"
      alert_summary     = "Critical | Postgres High CPU Percentage > 75%"
      alert_description = "Postgres CPU Percentage > 75%"
      timefor           = "5m"
      interval_seconds  = 240
      domain            = var.domain
      team              = var.team
      severity          = "P1"
      resource_type     = "psql"
      alert_type        = "Metrics"
      metricName        = "cpu_percent"
      dimensionFilters  = []
      metric_threshold  = 75
    }

    memory_percent = {
      subscription      = data.azurerm_subscription.current.subscription_id
      folderuid         = data.grafana_folder.folder.uid
      resourceGroup     = var.resource_group.name
      resourceName      = var.psql_server_name
      metricNamespace   = "microsoft.dbforpostgresql/flexibleservers"
      alert_name        = "PSQL| Postgres Memory Percentage > 75%"
      alert_summary     = "Critical | Postgres High Memory Percentage > 75%"
      alert_description = "Postgres Memory Percentage > 75%"
      timefor           = "5m"
      interval_seconds  = 240
      domain            = var.domain
      team              = var.team
      severity          = "P1"
      resource_type     = "psql"
      alert_type        = "Metrics"
      metricName        = "memory_percent"
      dimensionFilters  = []
      metric_threshold  = 75
    }

    storage_percent = {
      subscription      = data.azurerm_subscription.current.subscription_id
      folderuid         = data.grafana_folder.folder.uid
      resourceGroup     = var.resource_group.name
      resourceName      = var.psql_server_name
      metricNamespace   = "microsoft.dbforpostgresql/flexibleservers"
      alert_name        = "PSQL| Postgres Storage Percentage > 75%"
      alert_summary     = "Critical | Postgres High Storage Percentage > 75%"
      alert_description = "Postgres Storage Percentage > 75%"
      timefor           = "5m"
      interval_seconds  = 240
      domain            = var.domain
      team              = var.team
      severity          = "P1"
      resource_type     = "psql"
      alert_type        = "Metrics"
      metricName        = "storage_percent"
      dimensionFilters  = []
      metric_threshold  = 75
    }
  }
}

