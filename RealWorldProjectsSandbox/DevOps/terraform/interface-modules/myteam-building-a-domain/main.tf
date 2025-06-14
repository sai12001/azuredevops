locals {
  team                = join(",", var.with_domain_configs.team_name)
  domain_name         = var.with_domain_configs.domain_name
  resource_group_name = "${var.context.environment}-rg-${var.context.product}-${local.domain_name}-shared-${var.context.location_abbr}"

  # App Service Plan Config ========================
  needs_app_service_plans = defaults(var.needs_app_service_plans, {
    per_site_scaling         = false
    enable_autoscaling       = false
    profile_capacity_maximum = 1
    rulelist                 = ""
    enable_notification      = false
  })
  app_service_plans = { for asp in local.needs_app_service_plans : asp.asp_name => asp }

  # Key Vault Config ==============================
  key_vault_name = "${var.context.environment}-kv-${var.context.product}-${local.domain_name}-${var.context.location_abbr}"

  # NetWorking
  vnet_config = {
    resource_group = var.context.environment == "dev" ? "${var.context.environment}-rg-${var.context.product}-shared-infra-${var.context.location_abbr}" : "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
    name           = "${var.context.environment}-vnet-${var.context.product}-shared-${var.context.location_abbr}"
  }
  psql_subnet_name         = "subnet-psql"
  privatelinks_subnet_name = "subnet-privatelinks"
  private_dns_zones        = ["privatelink.documents.azure.com", "privatelink.database.windows.net"]

  # Private DNS Zone
  infra_resource_group  = "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
  psql_private_dns_name = var.context.environment == "prd" ? "shared.postgres.database.azure.com" : "shared.${var.context.environment}.postgres.database.azure.com"

  # CosmosDB
  cosmosdb_account = {
    primary_location                = try(var.needs_cosmos_dbs.primary_location, null)
    primary_location_zone_redundant = try(var.needs_cosmos_dbs.primary_location_zone_redundant, null)
    consistency_level               = try(var.needs_cosmos_dbs.consistency_level, null)
    offer_type                      = try(var.needs_cosmos_dbs.offer_type, null)
    kind                            = try(var.needs_cosmos_dbs.kind, null)
  }
  # postgresql server
  postgresql_server = var.needs_postgresql_server != null ? defaults(var.needs_postgresql_server, {
    server_version    = "13"
    server_username   = "psqladmin"
    server_storage_mb = 32768
    server_sku        = "B_Standard_B1ms"
    databases = {
      collation = "en_US.utf8"
      charset   = "UTF8"
    }
  }) : null

  # alerting
  alerts_emails = ["cloud@blackstream.com.au"]

  # Diagnostic Settings Config
  log_workspace = {
    name                = "${var.context.environment}-logs-${var.context.product}-workspace-${var.context.location_abbr}"
    resource_group_name = "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
  }
  # Tags ==============================
  tags = {
    domain = local.domain_name
  }

}
#########################################
#          DATA SOURCE
#########################################
data "azurerm_private_dns_zone" "psql_dns_zone" {
  name                = local.psql_private_dns_name
  resource_group_name = local.infra_resource_group
}

data "azurerm_virtual_network" "shared_vnet" {
  name                = local.vnet_config.name
  resource_group_name = local.vnet_config.resource_group
}

data "azurerm_subnet" "subnet_psql" {
  name                 = local.psql_subnet_name
  resource_group_name  = local.vnet_config.resource_group
  virtual_network_name = data.azurerm_virtual_network.shared_vnet.name
}

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

data "azurerm_key_vault_secret" "grafana_datasource_id" {
  name         = "ext-grafana-data-source-id"
  key_vault_id = data.azurerm_key_vault.infra_key_vault.id
}

data "azurerm_log_analytics_workspace" "law" {
  name                = local.log_workspace.name
  resource_group_name = local.log_workspace.resource_group_name
}

data "azurerm_sql_managed_instance" "sqlmi" {
  count               = var.need_tbs_db_access == null ? 0 : 1
  name                = var.need_tbs_db_access.sqlmi_instance
  resource_group_name = "${var.context.environment}-rg-${var.context.product}-tbs-sql"
}

#########################################
#          Source
#########################################

module "rg_domain" {
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
  resource_group        = module.rg_domain.resource_group
  tags                  = local.tags
  domain                = local.domain_name
  team                  = local.team
  depends_on = [
    module.rg_domain
  ]
}

module "grafana_app_service_plan" {
  for_each              = local.app_service_plans
  source                = "../../modules/app-service-plan/grafana"
  app_service_plan_name = each.value.asp_name
  resource_group        = module.rg_domain.resource_group
  context               = var.context
  team                  = local.team
  domain                = local.domain_name
  datasource_id         = data.azurerm_key_vault_secret.grafana_datasource_id.value
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

module "domain_key_vault" {
  source         = "../../modules/key-vault"
  resource_group = module.rg_domain.resource_group
  key_vault_name = local.key_vault_name
  context        = var.context
  environment    = var.context.environment
  tags           = local.tags
  depends_on = [
    module.rg_domain
  ]
}

module "domain_eventhub_namespace" {
  count                  = var.needs_an_eventhub_namespace == null ? 0 : 1
  source                 = "../../modules/event-hub"
  context                = var.context
  domain                 = local.domain_name
  team                   = local.team
  resource_group         = module.rg_domain.resource_group
  eventhub_namespace     = var.needs_an_eventhub_namespace
  tags                   = local.tags
  eventhub_metric_alerts = local.eventhub_metric_alerts
  depends_on = [
    module.rg_domain, module.domain_key_vault
  ]
}
module "grafana_eventhub" {
  count                   = var.needs_an_eventhub_namespace == null ? 0 : 1
  source                  = "../../modules/event-hub/grafana"
  context                 = var.context
  team                    = local.team
  resource_group          = module.rg_domain.resource_group
  domain                  = local.domain_name
  eventhub_namespace_name = module.domain_eventhub_namespace[0].eventhub_namespace_name
  datasource_id           = data.azurerm_key_vault_secret.grafana_datasource_id.value
}

module "cosmos_db" {
  count                     = var.needs_cosmos_dbs == null ? 0 : 1
  source                    = "../../modules/document-db"
  context                   = var.context
  domain                    = local.domain_name
  cosmos_name               = local.domain_name
  cosmosdb_account          = local.cosmosdb_account
  resource_group            = module.rg_domain.resource_group
  extra_cosmosdb_az_regions = { for region in var.needs_cosmos_dbs.extra_locaions : region.location => region }
  cosmosdb_sqldbs           = var.needs_cosmos_dbs.sql_databases
  vnet_config               = local.vnet_config
  subnets                   = data.azurerm_virtual_network.shared_vnet.subnets
  cosmo_db_metrics          = local.cosmo_db_metrics
  # datasource_id             = data.azurerm_key_vault_secret.grafana_datasource_id.value
  # Dashboard_Name            = "${local.domain_name} | CosmosDB Dashboard"
  # alert_short_name          = local.domain_name

  privatelink = {
    private_dns_zone_id = data.azurerm_private_dns_zone.private_dns_zones["privatelink.documents.azure.com"].id
    subnet_id           = data.azurerm_subnet.subnet_privatelinks.id
  }
  depends_on = [
    module.rg_domain, module.domain_key_vault
  ]
}

module "grafana_cosmos_db" {
  count          = var.needs_cosmos_dbs == null ? 0 : 1
  source         = "../../modules/document-db/grafana"
  context        = var.context
  resource_group = module.rg_domain.resource_group
  team           = local.team
  domain         = local.domain_name
  cosmos_name    = local.domain_name
  datasource_id  = data.azurerm_key_vault_secret.grafana_datasource_id.value
}

module "psql_server" {
  count            = var.needs_postgresql_server == null ? 0 : 1
  source           = "../../../../Devops/terraform/modules/postgresql-db/server"
  context          = var.context
  domain           = local.domain_name
  team             = local.team
  config           = local.postgresql_server
  resource_group   = module.rg_domain.resource_group
  psql_dns_zone_id = data.azurerm_private_dns_zone.psql_dns_zone.id
  psql_subnet_id   = data.azurerm_subnet.subnet_psql.id
  databases        = local.postgresql_server.databases
  # datasource_id    = data.azurerm_key_vault_secret.grafana_datasource_id.value
  # Dashboard_Name   = "${local.domain_name} | PSQL Server Dashboard"
  # alert_short_name = local.domain_name
  depends_on = [
    module.rg_domain, module.domain_key_vault
  ]
}

module "grafana_postgresql_db" {
  count            = var.needs_postgresql_server == null ? 0 : 1
  source           = "../../modules/postgresql-db/server/grafana"
  context          = var.context
  resource_group   = module.rg_domain.resource_group
  psql_server_name = module.psql_server[0].psql_server_name
  team             = local.team
  domain           = local.domain_name
  datasource_id    = data.azurerm_key_vault_secret.grafana_datasource_id.value
}

module "autoscaling" {
  source                   = "../../modules/autoscaling"
  for_each                 = local.app_service_plans
  enable_autoscaling       = each.value.enable_autoscaling
  context                  = var.context
  domain                   = local.domain_name
  resource_group           = module.rg_domain.resource_group
  resource_id              = module.app_service_plans[each.key].app_service_plan.id
  autoscale_name           = "${var.context.environment}-asg-${module.app_service_plans[each.key].app_service_plan.name}"
  profile_name             = "profile-${module.app_service_plans[each.key].app_service_plan.name}"
  profile_capacity_maximum = each.value.profile_capacity_maximum
  rulelist                 = each.value.rulelist
  enable_notification      = each.value.enable_notification
  email_custom_emails      = local.alerts_emails
  tags                     = local.tags
}

# namespace auth rules only
module "servicebus" {
  source                          = "../../modules/service-bus"
  context                         = var.context
  domain                          = local.domain_name
  resource_group                  = module.rg_domain.resource_group
  servicebus_namespace_auth_rules = var.need_servicebus_namespace_auth_rules
  tags                            = local.tags
  depends_on = [
    module.rg_domain, module.domain_key_vault
  ]
}

data "azurerm_key_vault_secret" "admin_user" {
  count        = var.need_tbs_db_access == null ? 0 : 1
  name         = "sqlmi-administrator-username-${var.need_tbs_db_access.sqlmi_instance}"
  key_vault_id = data.azurerm_key_vault.infra_key_vault.id
}

data "azurerm_key_vault_secret" "admin_password" {
  count        = var.need_tbs_db_access == null ? 0 : 1
  name         = "sqlmi-administrator-password-${var.need_tbs_db_access.sqlmi_instance}"
  key_vault_id = data.azurerm_key_vault.infra_key_vault.id
}

resource "random_password" "sqlmi_db_domain_user_password" {
  count   = var.need_tbs_db_access == null ? 0 : 1
  length  = 24
  special = false
  upper   = true
  lower   = true
}

resource "azurerm_key_vault_secret" "sqlmi_db_username" {
  count        = var.need_tbs_db_access == null ? 0 : 1
  key_vault_id = data.azurerm_key_vault.infra_key_vault.id
  name         = "sqlmi-${local.domain_name}-${var.need_tbs_db_access.sqlmi_instance}-user"
  value        = local.domain_name
  lifecycle {
    ignore_changes = [key_vault_id]
  }
}

resource "azurerm_key_vault_secret" "sqlmi_user_pwd" {
  count        = var.need_tbs_db_access == null ? 0 : 1
  key_vault_id = data.azurerm_key_vault.infra_key_vault.id
  name         = "sqlmi-${local.domain_name}-${var.need_tbs_db_access.sqlmi_instance}-password"
  value        = random_password.sqlmi_db_domain_user_password[0].result
  lifecycle {
    ignore_changes = [key_vault_id]
  }
}

resource "azurerm_key_vault_secret" "domain_sqlmi_connection_string" {
  count        = var.need_tbs_db_access == null ? 0 : 1
  key_vault_id = data.azurerm_key_vault.infra_key_vault.id
  name         = "sqlmi-connectionstring-${local.domain_name}-${data.azurerm_sql_managed_instance.sqlmi[0].name}"
  value        = "Server=tcp:${data.azurerm_sql_managed_instance.sqlmi[0].fqdn},1433;Persist Security Info=False;User ID=${local.domain_name};Password=${random_password.sqlmi_db_domain_user_password[0].result};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Application Name={0}"
  lifecycle {
    ignore_changes = [key_vault_id]
  }
}


resource "null_resource" "create_tbs_dbuser" {
  for_each = var.need_tbs_db_access != null ? { for db in var.need_tbs_db_access.databases : db.name => db } : {}
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = <<EOT
      .'${path.module}/../../../sharedScripts/Create_user_in_tbs.ps1' `
      -password '${azurerm_key_vault_secret.sqlmi_user_pwd[0].value}' `
      -databaseServer 'tcp:${data.azurerm_sql_managed_instance.sqlmi[0].fqdn},1433' `
      -AdminUser '${data.azurerm_key_vault_secret.admin_user[0].value}' `
      -AdminPassword '${data.azurerm_key_vault_secret.admin_password[0].value}' `
      -Login '${azurerm_key_vault_secret.sqlmi_db_username[0].value}' `
      -databases '${each.key}'
      EOT

    interpreter = ["PowerShell", "-Command"]
  }
}
