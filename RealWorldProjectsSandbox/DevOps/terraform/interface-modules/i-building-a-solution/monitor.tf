locals {
  cosmo_db_metrics = {
    RUConsumption_database = {
      description        = "Max RU consumption percentage per minute filtered by filtered by Database Name"
      metric_namespace   = "microsoft.documentdb/databaseaccounts"
      metric_name        = "NormalizedRUConsumption"
      aggregation        = "Maximum"
      operator           = "GreaterThan"
      threshold          = 75
      dimension_name     = "DatabaseName"
      dimension_operator = "Include"
      dimension_values   = ["*"]
    }

    RUConsumption_Collection = {
      description        = "Max RU consumption percentage per minute filtered by Collection Name"
      metric_namespace   = "microsoft.documentdb/databaseaccounts"
      metric_name        = "NormalizedRUConsumption"
      aggregation        = "Maximum"
      operator           = "GreaterThan"
      threshold          = 75
      dimension_name     = "CollectionName"
      dimension_operator = "Include"
      dimension_values   = ["*"]
    }

    RUConsumption_account = {
      description      = "Max RU consumption percentage per minute"
      metric_namespace = "microsoft.documentdb/databaseaccounts"
      metric_name      = "NormalizedRUConsumption"
      aggregation      = "Maximum"
      operator         = "GreaterThan"
      threshold        = 75
      dimension_name   = "No Dimensions"
    }

    ServerSideLatency_database = {
      description        = "Average Server Side Latency filtered by filtered by Database Name"
      metric_namespace   = "microsoft.documentdb/databaseaccounts"
      metric_name        = "ServerSideLatency"
      aggregation        = "Average"
      operator           = "GreaterThan"
      threshold          = 1000
      dimension_name     = "DatabaseName"
      dimension_operator = "Include"
      dimension_values   = ["*"]
    }

    ServerSideLatency_Collection = {
      description        = "Average Server Side Latency filtered by Collection Name"
      metric_namespace   = "microsoft.documentdb/databaseaccounts"
      metric_name        = "ServerSideLatency"
      aggregation        = "Average"
      operator           = "GreaterThan"
      threshold          = 1000
      dimension_name     = "CollectionName"
      dimension_operator = "Include"
      dimension_values   = ["*"]
    }

    ServerSideLatency_account = {
      description      = "Average Server Side Latency"
      metric_namespace = "microsoft.documentdb/databaseaccounts"
      metric_name      = "ServerSideLatency"
      aggregation      = "Average"
      operator         = "GreaterThan"
      threshold        = 1000
      dimension_name   = "No Dimensions"
    }

    TotalRequests_database = {
      description        = "Count Total Requests filtered by filtered by Database Name"
      metric_namespace   = "microsoft.documentdb/databaseaccounts"
      metric_name        = "TotalRequests"
      aggregation        = "Count"
      operator           = "GreaterThan"
      threshold          = 150
      dimension_name     = "DatabaseName"
      dimension_operator = "Include"
      dimension_values   = ["*"]
    }

    TotalRequests_Collection = {
      description        = "Count Total Requests filtered by Collection Name"
      metric_namespace   = "microsoft.documentdb/databaseaccounts"
      metric_name        = "TotalRequests"
      aggregation        = "Count"
      operator           = "GreaterThan"
      threshold          = 150
      dimension_name     = "CollectionName"
      dimension_operator = "Include"
      dimension_values   = ["*"]
    }

    TotalRequests_account = {
      description      = "Count Total Requests"
      metric_namespace = "microsoft.documentdb/databaseaccounts"
      metric_name      = "TotalRequests"
      aggregation      = "Count"
      operator         = "GreaterThan"
      threshold        = 150
      dimension_name   = "No Dimensions"
    }

  }
}

data "azurerm_key_vault_secret" "grafana_datasource_id" {
  name         = "ext-grafana-data-source-id"
  key_vault_id = data.azurerm_key_vault.infra_key_vault.id
}


module "grafana_cosmos_db" {
  count          = var.needs_cosmos_dbs != null && var.enable_grafana ? 1 : 0
  source         = "../../modules/document-db/grafana"
  context        = var.context
  resource_group = module.rg_solution.resource_group
  team           = local.team
  domain         = local.domain_name
  cosmos_name    = local.solution_name
  datasource_id  = data.azurerm_key_vault_secret.grafana_datasource_id.value
}


module "grafana_app_insights" {
  count             = var.enable_grafana ? 1 : 0
  source            = "../../modules/application-insights/grafana"
  context           = var.context
  resource_group    = module.rg_solution.resource_group
  team              = local.team
  domain            = local.domain_name
  app_insights_name = local.application_insights_name
  datasource_id     = data.azurerm_key_vault_secret.grafana_datasource_id.value
}


module "grafana_function_app" {
  source            = "../../modules/function-app-docker-asp/grafana"
  for_each          = var.enable_grafana ? local.function_apps : {}
  context           = var.context
  domain            = local.domain_name
  function_app_name = module.function_apps[each.key].function_app_name
  tags              = local.tags
}

module "grafana_web_app" {
  source      = "../../modules/web-app-docker-asp/grafana"
  for_each    = var.enable_grafana ? local.web_apps : {}
  context     = var.context
  domain      = local.domain_name
  webapp_name = module.web_apps[each.key].webapp_name
  tags        = local.tags
}
