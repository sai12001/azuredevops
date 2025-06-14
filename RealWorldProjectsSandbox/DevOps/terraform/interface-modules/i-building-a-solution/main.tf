locals {
  team                = var.with_solution_configs.team_name
  domain_name         = var.with_solution_configs.domain_name
  solution_name       = var.with_solution_configs.solution_name
  resource_group_name = "${var.context.environment}-rg-${var.context.product}-${local.solution_name}-${var.context.location_abbr}"

  # COSMOS DB Config ============================================================

  cosmosdb_account = {
    primary_location                = try(var.needs_cosmos_dbs.primary_location, null)
    primary_location_zone_redundant = try(var.needs_cosmos_dbs.primary_location_zone_redundant, null)
    consistency_level               = try(var.needs_cosmos_dbs.consistency_level, null)
    offer_type                      = try(var.needs_cosmos_dbs.offer_type, null)
    kind                            = try(var.needs_cosmos_dbs.kind, null)
  }

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

  data_asps = { for k, v in local.apps : k => {
    name                = "${var.context.environment}-asp-${var.context.product}-${local.domain_name}-${v.asp_name}-${var.context.location_abbr}"
    resource_group_name = "${var.context.environment}-rg-${var.context.product}-${local.domain_name}-shared-${var.context.location_abbr}"
  } }

  function_apps = { for app in local.with_apps_configs : app.app_name => app if app.app_type == "fnapp" }
  web_apps      = { for app in local.with_apps_configs : app.app_name => app if app.app_type == "webapp" }

  # Data Storage Accounts ===========================================
  data_storage_accounts = defaults(var.needs_storage_accounts, {
    account_tier             = "Standard"
    account_replication_type = "LRS"
  })


  # NetWorking ======================================================
  vnet_config = {
    resource_group = var.context.environment == "dev" ? "${var.context.environment}-rg-${var.context.product}-shared-infra-${var.context.location_abbr}" : "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
    name           = "${var.context.environment}-vnet-${var.context.product}-shared-${var.context.location_abbr}"
  }
  psql_subnet_name         = "subnet-psql"
  privatelinks_subnet_name = "subnet-privatelinks"
  private_dns_zones        = ["privatelink.documents.azure.com"]


  # storage account
  sta_suffix = random_string.storage_suffix.result

  # PostgreSQL DBs
  postgresql_dbs = defaults(var.needs_postgresql_databases, {
    collation = "en_US.utf8"
    charset   = "UTF8"
  })


  # need to disable all the access after the deployment
  # az resource list  --resource-type "Microsoft.Web/sites" --query "[].{Name:name, Id:id}"
  # az resource list  --resource-type "Microsoft.Web/sites/slots" --query "[].{Name:name, Id:id}"

  # az resource update ids <<webapp ids>> --set properties.siteConfig.ipSecurityRestrictionsDefaultAction=Deny --set properties.siteConfig.scmIpSecurityRestrictionsDefaultAction=Deny
  # az resource update --ids <<slot ids>>  --set properties.siteConfig.ipSecurityRestrictionsDefaultAction=Deny --set properties.siteConfig.scmIpSecurityRestrictionsDefaultAction=Deny

  domains = concat([local.domain_name], local.domain_access_maps[local.domain_name])

  access_allowed_subnets = concat(flatten([for d in local.domains :
    [for subnet in data.azurerm_virtual_network.shared_vnet.subnets : subnet if length(regexall(d, subnet)) > 0]
  ]), var.extra_subnet_access)

  pentest_cobalt_ips = [
    "34.82.99.36/32", "34.95.145.221/32", "34.105.164.255/32", "34.107.83.48/32",
    "34.124.205.48/32", "34.131.190.84/32", "35.189.46.39/32", "35.198.150.95/32", "35.200.159.241/32",
    "35.221.55.248/32", "35.245.116.24/32"
  ]

  pentest_colbalt_ip_rules = [for i in range(length(local.pentest_cobalt_ips)) : {
    action                    = "Allow"
    name                      = format("pentest_cobalt_%d", i)
    headers                   = []
    priority                  = 400 + i
    service_tag               = null
    ip_address                = local.pentest_cobalt_ips[i]
    virtual_network_subnet_id = null
    }
  ]
  office_ip_rules = [
    {
      action                    = "Allow"
      name                      = "Office IP",
      headers                   = []
      priority                  = 100
      service_tag               = null
      ip_address                = "139.130.32.10/32"
      virtual_network_subnet_id = null
    },
    {
      action                    = "Allow"
      name                      = "Private Probe",
      headers                   = []
      priority                  = 110
      service_tag               = null
      ip_address                = null
      virtual_network_subnet_id = "/subscriptions/d877ef00-ea85-4a82-816c-b437fb7b1ebc/resourceGroups/rg-core-infra-network/providers/Microsoft.Network/virtualNetworks/prod-vnet-utils-services/subnets/subnet-jumpboxs"
    }
  ]

  extra_default_rules = var.context.environment == "stg" && length(regexall(".*-xl.*", local.solution_name)) > 0 ? local.pentest_colbalt_ip_rules : []

  default_rules = concat(local.office_ip_rules, local.extra_default_rules)
  app_access_rules = [for name, subnet in data.azurerm_subnet.allowed_access_subnets : {
    action                    = "Allow"
    name                      = subnet.name,
    headers                   = []
    priority                  = 200 + 10 * index(keys(data.azurerm_subnet.allowed_access_subnets), name)
    service_tag               = null
    ip_address                = null
    virtual_network_subnet_id = subnet.id
    }
  ]

  cloud_flare_ips = [
    "173.245.48.0/20",
    "103.21.244.0/22",
    "103.22.200.0/22",
    "103.31.4.0/22",
    "141.101.64.0/18",
    "108.162.192.0/18",
    "190.93.240.0/20",
    "188.114.96.0/20",
    "197.234.240.0/22",
    "198.41.128.0/17",
    "162.158.0.0/15",
    "104.16.0.0/13",
    "104.24.0.0/14",
    "172.64.0.0/13",
    "131.0.72.0/22"
  ]

  cloud_flare_ip_rules = [for i in range(length(local.cloud_flare_ips)) : {
    action                    = "Allow"
    name                      = format("cloud_flare_%d", i)
    headers                   = []
    priority                  = 300 + 10 * i
    service_tag               = null
    ip_address                = local.cloud_flare_ips[i]
    virtual_network_subnet_id = null
    }
  ]



  cf_token_secret_name   = "ext-cloudflare-dns-api-token"
  cf_zone_id_secret_name = "ext-cloudflare-zone-id"

  # shared infra resource group
  infra_resource_group = "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"

  # Tags ============================================================
  tags = {
    solution_name = local.solution_name
    domain        = local.domain_name
  }
}

#########################################
#          DATA SOURCE
#########################################

data "azurerm_subnet" "subnet_privatelinks" {
  name                 = local.privatelinks_subnet_name
  virtual_network_name = local.vnet_config.name
  resource_group_name  = local.vnet_config.resource_group
}
data "azurerm_private_dns_zone" "private_dns_zones" {
  for_each            = toset(local.private_dns_zones)
  name                = each.key
  resource_group_name = local.infra_resource_group
}

data "azurerm_service_plan" "asp" {
  for_each            = local.data_asps
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
}

data "azurerm_virtual_network" "shared_vnet" {
  name                = local.vnet_config.name
  resource_group_name = local.vnet_config.resource_group
}

data "azurerm_subnet" "asp_subnets" {
  for_each             = local.apps
  name                 = "subnet-${local.domain_name}-${each.value.asp_name}"
  virtual_network_name = local.vnet_config.name
  resource_group_name  = local.vnet_config.resource_group
}

data "azurerm_subnet" "allowed_access_subnets" {
  for_each             = toset(local.access_allowed_subnets)
  name                 = each.key
  virtual_network_name = local.vnet_config.name
  resource_group_name  = local.vnet_config.resource_group
}


data "azurerm_log_analytics_workspace" "law" {
  name                = local.log_workspace.name
  resource_group_name = local.log_workspace.resource_group_name
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



module "cosmos_db" {
  count                     = var.needs_cosmos_dbs == null ? 0 : 1
  source                    = "../../modules/document-db"
  context                   = var.context
  domain                    = local.domain_name
  cosmos_name               = local.solution_name
  cosmosdb_account          = local.cosmosdb_account
  resource_group            = module.rg_solution.resource_group
  extra_cosmosdb_az_regions = { for region in var.needs_cosmos_dbs.extra_locaions : region.location => region }
  cosmosdb_sqldbs           = var.needs_cosmos_dbs.sql_databases
  vnet_config               = local.vnet_config
  cosmo_db_metrics          = local.cosmo_db_metrics

  privatelink = {
    private_dns_zone_id = data.azurerm_private_dns_zone.private_dns_zones["privatelink.documents.azure.com"].id
    subnet_id           = data.azurerm_subnet.subnet_privatelinks.id
  }
  depends_on = [
    module.rg_solution
  ]
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

# storage account for data
module "sta_data" {
  for_each                 = { for sta in local.data_storage_accounts : sta.name => sta }
  source                   = "../../modules/storage-account"
  context                  = var.context
  domain                   = local.domain_name
  resource_group           = module.rg_solution.resource_group
  account_name             = lower(substr(replace("${var.context.environment}sta${var.context.product}${each.key}${local.sta_suffix}", "-", ""), 0, 24))
  account_tier             = each.value.account_tier
  account_replication_type = each.value.account_replication_type
  containers               = each.value.containers
  queues                   = each.value.queues
  tables                   = each.value.tables
  cors_rules               = each.value.cors_allowed_origins
  tags                     = local.tags
  depends_on = [
    random_string.storage_suffix, module.rg_solution
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

module "eventhubs" {
  source          = "../../modules/event-hub"
  context         = var.context
  domain          = local.domain_name
  team            = local.team
  resource_group  = module.rg_solution.resource_group
  eventhubs       = var.needs_eventhubs
  consumer_groups = var.needs_consumer_groups
  auth_rules      = var.needs_eh_auth_rules
  tags            = local.tags

  depends_on = [
    module.rg_solution
  ]
}

module "servicebus" {
  source                         = "../../modules/service-bus"
  context                        = var.context
  domain                         = local.domain_name
  resource_group                 = module.rg_solution.resource_group
  servicebus_queues              = var.needs_servicebus_queues
  servicebus_topics              = var.needs_servicebus_topics
  servicebus_queue_auth_rules    = var.needs_servicebus_queue_auth_rules
  servicebus_topic_auth_rules    = var.needs_servicebus_topic_auth_rules
  servicebus_topic_subscriptions = var.needs_servicebus_topic_subscriptions
  tags                           = local.tags
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
  storage_account      = module.sta_app.storage_account
  application_insights = module.application_insights.application_insights
  app_service_plan_id  = data.azurerm_service_plan.asp[each.key].id
  app_settings         = each.value.plain_text_settings
  secure_settings      = each.value.secure_settings
  connection_strings   = each.value.connection_strings
  enable_local_logging = each.value.enable_local_logging
  health_check_path    = each.value.health_check_path
  subnet_id            = data.azurerm_subnet.asp_subnets[each.key].id
  tags                 = local.tags
  access_rules         = concat(local.default_rules, local.app_access_rules)
  exposed_to_apim      = each.value.exposed_to_apim

  # privatelink = {
  #   private_dns_zone_id = data.azurerm_private_dns_zone.private_dns_zones["privatelink.azurewebsites.net"].id
  #   subnet_id           = data.azurerm_subnet.subnet_privatelinks.id
  # }
  depends_on = [
    module.sta_app, module.cosmos_db, module.eventhubs
  ]
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
  application_insights = module.application_insights.application_insights
  app_service_plan_id  = data.azurerm_service_plan.asp[each.key].id
  app_settings         = each.value.plain_text_settings
  secure_settings      = each.value.secure_settings
  connection_strings   = each.value.connection_strings
  health_check_path    = each.value.health_check_path
  subnet_id            = data.azurerm_subnet.asp_subnets[each.key].id
  enable_local_logging = each.value.enable_local_logging
  required_custom_dns  = each.value.required_custom_dns
  access_rules         = each.value.required_custom_dns != null ? concat(local.default_rules, local.app_access_rules, local.cloud_flare_ip_rules) : concat(local.default_rules, local.app_access_rules)
  tags                 = local.tags
  depends_on = [
    module.cosmos_db, module.eventhubs
  ]
}



module "psql_dbs" {
  count          = length(var.needs_postgresql_databases) > 0 ? 1 : 0
  source         = "../../modules/postgresql-db/databases"
  context        = var.context
  domain         = local.domain_name
  resource_group = module.rg_solution.resource_group
  databases      = local.postgresql_dbs
  depends_on = [
    module.rg_solution
  ]
}
