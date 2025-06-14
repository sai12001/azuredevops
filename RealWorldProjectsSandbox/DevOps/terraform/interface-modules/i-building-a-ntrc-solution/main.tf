locals {
  team                = var.with_solution_configs.team_name
  domain_name         = "ntrc"
  solution_name       = var.with_solution_configs.solution_name
  resource_group_name = "${var.context.environment}-rg-${var.context.product}-${local.solution_name}-${var.context.location_abbr}"
  # App Service Plan Config ========================
  with_app_service_plans = defaults(var.with_app_service_plans, {
    per_site_scaling         = false
    enable_autoscaling       = false
    profile_capacity_maximum = 1
    rulelist                 = ""
    enable_notification      = false
  })
  app_service_plans = { for asp in local.with_app_service_plans : asp.asp_name => asp }

  # App Config ============================================================
  application_insights_name = "${var.context.environment}-ai-${var.context.product}-${local.solution_name}-${var.context.location_abbr}"
  storage_account_name      = lower(substr(replace("${var.context.environment}sta${var.context.product}${local.solution_name}${var.context.location_abbr}${random_string.storage_suffix.result}", "-", ""), 0, 24))
  log_workspace = {
    name                = "${var.context.environment}-logs-${var.context.product}-workspace-${var.context.location_abbr}"
    resource_group_name = "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
  }
  with_apps_configs = defaults(var.with_apps_configs, {
    app_type             = "fnapp"
    exposed_to_apim      = false
    enable_local_logging = false
  })

  apps = { for app in local.with_apps_configs : app.app_name => app }

  function_apps = { for app in local.with_apps_configs : app.app_name => app if app.app_type == "fnapp" }
  web_apps      = { for app in local.with_apps_configs : app.app_name => app if app.app_type == "webapp" }

  # NetWorking ======================================================
  vnet_config = {
    resource_group = "${var.context.environment}-rg-${var.context.product}-ntrc-shared-eau"
    name           = "${var.context.environment}-vnet-${var.context.product}-ntrc-eau"
  }
  # storage account
  sta_suffix = random_string.storage_suffix.result
  # Tags ============================================================
  tags = {
    solution_name = local.solution_name
    domain        = local.domain_name
    scope         = "ntrc"
  }
  # Cloudflare
  cf_token_secret_name   = "ext-cloudflare-dns-api-token"
  cf_zone_id_secret_name = "ext-cloudflare-zone-id"
}

#########################################
#          Data Source
#########################################
data "azurerm_log_analytics_workspace" "law" {
  name                = local.log_workspace.name
  resource_group_name = local.log_workspace.resource_group_name
}

data "azurerm_key_vault_secret" "grafana_datasource_id" {
  name         = "ext-grafana-data-source-id"
  key_vault_id = data.azurerm_key_vault.infra_key_vault.id
}



#########################################
#          Source
#########################################

resource "random_string" "storage_suffix" {
  length  = 24
  special = false
  lower   = true
  upper   = false
  number  = false
}

module "rg_solution" {
  source              = "../../modules/resource-group"
  context             = var.context
  belong_to_team      = local.team
  resource_group_name = local.resource_group_name
  tags                = local.tags
}

module "app_service_plans" {
  source                = "../../modules/app-service-plan"
  for_each              = local.app_service_plans
  context               = var.context
  app_service_plan_name = each.value.asp_name
  per_site_scaling      = each.value.per_site_scaling
  sku_name              = each.value.sku_name
  resource_group        = module.rg_solution.resource_group
  tags                  = local.tags
  domain                = local.domain_name
  team                  = local.team
  depends_on = [
    module.rg_solution
  ]
}

resource "azurerm_subnet" "subnets" {
  for_each             = local.app_service_plans
  name                 = "subnet-${local.domain_name}-${each.value.asp_name}"
  resource_group_name  = local.vnet_config.resource_group
  virtual_network_name = local.vnet_config.name
  address_prefixes     = ["${each.value.subnet_cidr}"]

  delegation {
    name = "delegation"

    service_delegation {
      name = "Microsoft.Web/serverFarms"
    }
  }
  service_endpoints = ["Microsoft.AzureCosmosDB", "Microsoft.ServiceBus", "Microsoft.Sql", "Microsoft.Storage", "Microsoft.Web", "Microsoft.KeyVault"]
  depends_on = [
    module.app_service_plans
  ]
  lifecycle {
    ignore_changes = [
      delegation["service_delegation"]
    ]
  }
}

resource "azurerm_network_security_group" "nsg_asps" {
  for_each            = local.app_service_plans
  name                = "${var.context.environment}-nsg-${var.context.product}-${azurerm_subnet.subnets[each.key].name}"
  location            = var.context.location
  resource_group_name = local.resource_group_name
}

resource "azurerm_subnet_network_security_group_association" "nsg_association_asps" {
  for_each                  = local.app_service_plans
  subnet_id                 = azurerm_subnet.subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg_asps[each.key].id
}

# storage account for function app
# hardcode the values here, as they are required for function apps
module "sta_app" {
  source                   = "../../modules/storage-account"
  context                  = var.context
  domain                   = local.domain_name
  resource_group           = module.rg_solution.resource_group
  account_name             = local.storage_account_name
  account_replication_type = "GRS"
  # Leave this as hardcoded because Function App is looking for this cotnainer
  containers = [{
    name        = "azure-webjobs-secrets"
    access_type = "private"
  }]
  tags = local.tags

  depends_on = [
    module.rg_solution
  ]
}


module "application_insights" {
  source                    = "../../modules/application-insights"
  application_insights_name = local.application_insights_name
  resource_group            = module.rg_solution.resource_group
  log_workspace             = local.log_workspace
  tags                      = local.tags
  domain                    = local.domain_name
  team                      = local.team
  environment               = var.context.environment
  depends_on = [
    module.rg_solution
  ]
}

module "function_apps" {
  source               = "../../modules/function-app-docker-asp"
  for_each             = local.function_apps
  resource_group       = module.rg_solution.resource_group
  context              = var.context
  domain               = local.domain_name
  solution_name        = local.solution_name
  function_app_name    = each.key
  worker_count         = each.value.worker_count
  cors_allowed_origins = each.value.cors_allowed_origins
  storage_account      = module.sta_app.storage_account
  application_insights = module.application_insights.application_insights
  app_service_plan_id  = module.app_service_plans[each.value.asp_name].app_service_plan.id
  app_settings         = each.value.plain_text_settings
  secure_settings      = each.value.secure_settings
  enable_local_logging = each.value.enable_local_logging
  subnet_id            = azurerm_subnet.subnets[each.value.asp_name].id
  access_rules         = each.value.access_rules
  tags                 = local.tags
  exposed_to_apim      = false
  depends_on = [
    module.sta_app, module.app_service_plans, azurerm_subnet.subnets
  ]
}

module "grafana_function_app" {
  source            = "../../modules/function-app-docker-asp/grafana"
  for_each          = local.function_apps
  context           = var.context
  domain            = local.domain_name
  function_app_name = module.function_apps[each.key].function_app_name
  tags              = local.tags
}

module "web_apps" {
  source               = "../../modules/web-app-docker-asp"
  for_each             = local.web_apps
  resource_group       = module.rg_solution.resource_group
  context              = var.context
  domain               = local.domain_name
  solution_name        = local.solution_name
  webapp_name          = each.key
  worker_count         = each.value.worker_count
  cors_allowed_origins = each.value.cors_allowed_origins
  application_insights = module.application_insights.application_insights
  app_service_plan_id  = module.app_service_plans[each.value.asp_name].app_service_plan.id
  app_settings         = each.value.plain_text_settings
  secure_settings      = each.value.secure_settings
  subnet_id            = azurerm_subnet.subnets[each.value.asp_name].id
  access_rules         = each.value.access_rules
  enable_local_logging = each.value.enable_local_logging
  tags                 = local.tags
  depends_on = [
    module.app_service_plans, azurerm_subnet.subnets
  ]
}

module "grafana_web_app" {
  source      = "../../modules/web-app-docker-asp/grafana"
  for_each    = local.web_apps
  context     = var.context
  domain      = local.domain_name
  webapp_name = module.web_apps[each.key].webapp_name
  tags        = local.tags
}
