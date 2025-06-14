locals {
  asp_for_dashboard = [for asp in local.app_service_plans : {
    abbr_name      = "${local.domain_name}-${asp.asp_name}"
    full_name      = "${var.context.environment}-asp-ng-${local.domain_name}-${asp.asp_name}-eau"
    resource_group = module.rg_domain.resource_group.name
    }
  ]

  docdb_for_dashboard = [for cosmos in data.azurerm_resources.domain_cosmos_dbs.resources : {
    display_name   = cosmos.name
    full_name      = cosmos.name
    resource_group = split("/", cosmos.id)[4]
    }
  ]

  ai_for_dashboard = [for ai in data.azurerm_resources.app_insights.resources : {
    display_name   = ai.name
    full_name      = ai.name
    resource_group = split("/", ai.id)[4]
    }
  ]
}

module "cent_asp_dash" {
  source            = "../../modules/centralized_dashboards/app-service-plan"
  domain_name       = local.domain_name
  environment       = var.context.environment
  AzureDataSourceID = data.azurerm_key_vault_secret.grafana_datasource_id.value
  app_service_plans = local.asp_for_dashboard
}

module "cent_docdb_dash" {
  count             = length(data.azurerm_resources.domain_cosmos_dbs.resources) != 0 ? 1 : 0
  source            = "../../modules/centralized_dashboards/cosmos-db"
  domain_name       = local.domain_name
  dashboard_name    = "${upper(local.domain_name)} Domain Cosmos DB Accounts"
  environment       = var.context.environment
  AzureDataSourceID = data.azurerm_key_vault_secret.grafana_datasource_id.value
  cosmosdbs         = local.docdb_for_dashboard
}

module "cent_ai_dash" {
  source            = "../../modules/centralized_dashboards/application-insights"
  domain_name       = local.domain_name
  environment       = var.context.environment
  AzureDataSourceID = data.azurerm_key_vault_secret.grafana_datasource_id.value
  app_insights      = local.ai_for_dashboard
}

data "azurerm_resources" "domain_cosmos_dbs" {
  type = "microsoft.documentdb/databaseaccounts"
  required_tags = {
    domain = local.domain_name
  }
}

data "azurerm_resources" "app_insights" {
  type = "microsoft.insights/components"
  required_tags = {
    domain = local.domain_name
  }
}