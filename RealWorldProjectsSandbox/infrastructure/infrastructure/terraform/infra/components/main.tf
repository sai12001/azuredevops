locals {
  tags = {
    provisioner = "terraform"
    domain      = var.domain_name
    environment = var.environment
    location    = var.location_abbr
    product     = var.product
    team        = var.team_name
  }
  context = {
    product       = var.product
    environment   = var.environment
    location      = var.location
    domain        = var.domain_name
    location_abbr = var.location_abbr
  }
  # only alpha numberic supported
  acr_name            = "${var.environment}acr${var.product}${var.domain_name}main${var.location_abbr}"
  resource_group_name = "${var.environment}-rg-${var.product}-${var.domain_name}-shared-${var.location_abbr}"
  key_vault_name      = "${var.environment}-kv-${var.product}-${var.domain_name}-${var.location_abbr}"
  log_workspace_name  = "${var.environment}-logs-${var.product}-workspace-${var.location_abbr}"

  cf_token_secret_name   = "ext-cloudflare-dns-api-token"
  cf_zone_id_secret_name = "ext-cloudflare-zone-id"

  non_prod_allowed_origins = {
    dev_origins = var.environment != "dev" ? "" : <<EOT
      <origin>http://localhost/</origin>
      <origin>https://localhost/</origin>
      <origin>http://localhost:4200/</origin>
      <origin>https://localhost:4200/</origin>
    EOT

    origins = <<CORS
      <origin>https://${var.environment}.${var.apim_config.base_dns}/</origin>
      <origin>http://${var.environment}.${var.apim_config.base_dns}/</origin>
      <origin>https://cms-${var.environment}.${var.apim_config.base_dns}/</origin>
      <origin>https://${var.environment}.surge.com.au/</origin>
    CORS
  }

  allowed_origins = {
    dev_origins = ""
    origins     = <<CORS
      <origin>https://${var.environment}.${var.apim_config.base_dns}/</origin>
      <origin>http://${var.environment}.${var.apim_config.base_dns}/</origin>
      <origin>https://cms.${var.apim_config.base_dns}/</origin>
      <origin>https://www.surge.com.au/</origin>
    CORS
  }


  apim_product_policies = {
    "xl"         = templatefile("${path.module}/apim_product_policies/xl-policy.xml", var.environment == "prd" ? local.allowed_origins : local.non_prod_allowed_origins)
    "backoffice" = templatefile("${path.module}/apim_product_policies/backoffice-policy.xml", var.environment == "prd" ? local.allowed_origins : local.non_prod_allowed_origins)
  }

  # API Management Dashboard Path
  apim_dashboard_path = "dashboard_templates/apim_dashboard_template.tpl"

  key_vault = {
    resource_group_name = data.azurerm_key_vault.infra_key_vault.resource_group_name
    key_vault_name      = data.azurerm_key_vault.infra_key_vault.name
  }
}

###########################################################
#         DATA Sources
###########################################################
data "azurerm_key_vault" "infra_key_vault" {
  name                = "${var.environment}-kv-${var.product}-infra-${var.location_abbr}"
  resource_group_name = "${var.environment}-rg-${var.product}-infra-shared-${var.location_abbr}"
}


###########################################################
#         Sources
###########################################################

module "rg_sql_mi" {
  source              = "../../../../../DevOps/terraform/modules/resource-group"
  context             = local.context
  belong_to_team      = var.team_name
  resource_group_name = var.sql_mi.resource_group
  tags                = local.tags
  prevent_destroy     = true
}

module "rg_sql_mi_load_test" {
  count               = var.sql_mi_load_test == null ? 0 : 1
  source              = "../../../../../DevOps/terraform/modules/resource-group"
  context             = local.context
  belong_to_team      = var.team_name
  resource_group_name = var.sql_mi_load_test.resource_group
  tags                = local.tags
  prevent_destroy     = true
}

module "rg_databricks" {
  source              = "../../../../../DevOps/terraform/modules/resource-group"
  context             = local.context
  belong_to_team      = var.team_name
  resource_group_name = var.databricks.resource_group
  tags                = local.tags
  prevent_destroy     = false
}

module "rg_powerbi" {
  source              = "../../../../../DevOps/terraform/modules/resource-group"
  context             = local.context
  belong_to_team      = var.team_name
  resource_group_name = var.powerbi.resource_group
  tags                = local.tags
  prevent_destroy     = false
}

# shared log analytics workspace
resource "azurerm_log_analytics_workspace" "log_workspace" {
  name                = local.log_workspace_name
  location            = var.rg_infra.location
  resource_group_name = var.rg_infra.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  daily_quota_gb      = var.environment != "prd" ? 20 : -1
  tags                = local.tags

  lifecycle {
    ignore_changes  = [name, location, sku, retention_in_days]
    prevent_destroy = true
  }
}

#  security groups to control access
module "network-security-group" {
  for_each                = var.nsg_configs
  source                  = "../../../../../Devops/terraform/modules/network-security-group"
  resource_group          = var.rg_infra
  context                 = local.context
  security_group_name     = each.key
  domain                  = var.domain_name
  predefined_rules        = each.value.predefined_rules
  custom_rules            = each.value.custom_rules
  log_analytics_retention = var.log_analytics_retention
}

# databricks workspace and cluster
module "databricks_workspace" {
  source                         = "../../../../../DevOps/terraform/modules/databricks"
  context                        = local.context
  databricks_workspace_name      = var.databricks.databricks_workspace_name
  databricks_sku                 = var.databricks.databricks_sku
  storage_account_sku_name       = var.databricks.storage_account_sku_name
  location                       = var.location
  location_abbr                  = var.location_abbr
  vnet_name                      = var.databricks.vnet_name
  vnet_resource_group            = var.databricks.vnet_resource_group
  private_subnet_name            = var.databricks.private_subnet_name
  public_subnet_name             = var.databricks.public_subnet_name
  databricks_driver_node_type_id = var.databricks.driver_node_type_id
  databricks_spark_version       = var.databricks.spark_version
  resource_group                 = module.rg_databricks.resource_group
  network_security_group_rules   = var.databricks.network_security_group_rules
  log_analytics_retention        = var.log_analytics_retention
  containers                     = var.databricks.containers
  blobs                          = var.databricks.blobs
  task_configuration             = var.databricks.task_configuration
  task_configuration_one_off     = var.databricks.task_configuration_one_off
  branch                         = var.databricks.branch
}

#powerbi embedded resource
module "powerbi" {
  source         = "../../../../../DevOps/terraform/modules/powerbi-embedded"
  context        = local.context
  location       = var.location
  administrators = var.powerbi.administrators
  resource_group = module.rg_powerbi.resource_group
  sku_name       = var.powerbi.sku_name
}

# sql managed instance
module "sqlmi_instance" {
  source         = "../../../../../DevOps/terraform/modules/sql-managed-instance"
  context        = local.context
  instance_name  = var.sql_mi.instance_name
  resource_group = module.rg_sql_mi.resource_group
  vnet_config    = var.shared_vnet_config

  administrator_login = var.sql_mi.administrator_login
  db_user             = var.sql_mi.db_user

  collation            = var.sql_mi.collation
  vcores               = var.sql_mi.vcores
  storage_account_type = var.sql_mi.storage_account_type
  storage_size_in_gb   = var.sql_mi.storage_size_in_gb

  proxy_override = var.sql_mi.proxy_override
  timezone_id    = var.sql_mi.timezone_id
  license_type   = var.sql_mi.license_type
  sku_name       = var.sql_mi.sku_name

  public_data_endpoint_enabled = var.sql_mi.public_data_endpoint_enabled
  subnet_name                  = var.sql_mi.subnet_name
  network_security_group_rules = var.sql_mi.network_security_group_rules

  log_analytics_retention = var.log_analytics_retention

  key_vault = local.key_vault

  depends_on = [
    module.action_group,
    grafana_folder.folders
  ]
}

module "sqlmi_instance_load_test" {
  count          = var.sql_mi_load_test == null ? 0 : 1
  source         = "../../../../../DevOps/terraform/modules/sql-managed-instance"
  context        = local.context
  instance_name  = var.sql_mi_load_test.instance_name
  resource_group = module.rg_sql_mi_load_test[0].resource_group
  vnet_config    = var.shared_vnet_config

  administrator_login = var.sql_mi_load_test.administrator_login
  db_user             = var.sql_mi_load_test.db_user

  collation            = var.sql_mi_load_test.collation
  vcores               = var.sql_mi_load_test.vcores
  storage_account_type = var.sql_mi_load_test.storage_account_type
  storage_size_in_gb   = var.sql_mi_load_test.storage_size_in_gb

  proxy_override = var.sql_mi_load_test.proxy_override
  timezone_id    = var.sql_mi_load_test.timezone_id
  license_type   = var.sql_mi_load_test.license_type
  sku_name       = var.sql_mi_load_test.sku_name

  public_data_endpoint_enabled = var.sql_mi_load_test.public_data_endpoint_enabled
  subnet_name                  = var.sql_mi_load_test.subnet_name
  network_security_group_rules = var.sql_mi_load_test.network_security_group_rules

  log_analytics_retention = var.log_analytics_retention

  key_vault = local.key_vault

  depends_on = [
    module.action_group,
    grafana_folder.folders
  ]
}

# container registry for this environment
resource "azurerm_container_registry" "acr" {
  name                = local.acr_name
  resource_group_name = var.rg_infra.name
  location            = var.rg_infra.location
  sku                 = var.acr_config.sku
  admin_enabled       = var.acr_config.admin_enabled
  tags                = local.tags
}

# shared service bus namespace, this namespace is used by all domains
module "servicebus_namespace" {
  source                  = "../../../../../DevOps/terraform/modules/service-bus"
  context                 = local.context
  domain                  = var.domain_name
  resource_group          = var.rg_infra
  log_analytics_retention = var.log_analytics_retention
  datasource_id           = data.azurerm_key_vault_secret.grafana_datasource_id.value
  servicebus_namespace = {
    sku = var.servicebus_config.sku
  }
  depends_on = [
    module.action_group,
    grafana_folder.folders
  ]
}

# shared action groups for this environment
module "action_group" {
  source         = "../../../../../DevOps/terraform/modules/action-group"
  context        = local.context
  domain         = var.domain_name
  resource_group = var.rg_infra
  action_groups  = var.action_groups
}

# apim instance for this environment
module "apim" {
  source           = "../../../../../DevOps/terraform/modules/api-management/apim-instance"
  context          = local.context
  domain           = var.domain_name
  resource_group   = var.rg_infra
  product_policies = local.apim_product_policies
  redis_cache_name = module.redis-cache.instance.name
  apim_configs = {
    publisher_name  = var.apim_config.publisher_name
    publisher_email = var.apim_config.publisher_email
    sku_name        = var.apim_config.sku_name
    base_dns        = var.apim_config.base_dns
  }
  vnet_config = var.shared_vnet_config

  # API Management Dashboard Parameters
  apim_dashboard_path = local.apim_dashboard_path
  apim_dashboard_name = var.apim_config.dashboard_name

  # API Management Metric Alert Configuration
  apim_metric_alert = var.apim_metric_alert

  # API Management Action Group Configuration
  apim_enable_action_group = var.apim_config.enable_action_group
  ag_short_name            = var.action_groups["sre"].ag_short_name

  log_analytics_retention = var.log_analytics_retention

  # Adding Certificates
  certificates = var.apim_certificates

  depends_on = [
    var.rg_infra,
    module.action_group,
    grafana_folder.folders
  ]
}

# signalr instance for this environment
module "signalr" {
  source          = "../../../../../DevOps/terraform/modules/signalr"
  context         = local.context
  domain          = var.domain_name
  resource_group  = var.rg_infra
  sku             = var.signalr_config.sku
  allowed_origins = var.signalr_config.allowed_origins

  connectivity_logs_enabled = var.signalr_config.connectivity_logs_enabled
  messaging_logs_enabled    = var.signalr_config.messaging_logs_enabled
  live_trace_enabled        = var.signalr_config.live_trace_enabled
  service_mode              = var.signalr_config.service_mode

  # Upstream Endpoint
  category_pattern = var.signalr_config.category_pattern
  hub_pattern      = var.signalr_config.hub_pattern
  url_template     = var.signalr_config.url_template

  # Metric Alert Configuration
  metric_alert = var.signalr_metric_alert

  # Action Group Configuration
  enable_action_group = var.signalr_config.enable_action_group
  ag_short_name       = var.action_groups["sre"].ag_short_name

  log_analytics_retention = var.log_analytics_retention

  depends_on = [
    module.action_group,
    grafana_folder.folders
  ]
}


# shared redis cache
module "redis-cache" {
  source                  = "../../../../../Devops/terraform/modules/redis-cache"
  context                 = local.context
  domain                  = var.domain_name
  resource_group          = var.rg_infra
  capacity                = var.redis_config.capacity
  family                  = var.redis_config.family
  sku_name                = var.redis_config.sku_name
  log_analytics_retention = var.log_analytics_retention
}

# Azure AutoManage
module "automange" {
  source  = "../../../../../Devops/terraform/modules/automanage"
  context = local.context
}

resource "random_string" "storage_suffix" {
  length  = 24
  special = false
  lower   = true
  upper   = false
  number  = false
}

module "static_storage_account" {
  for_each                 = toset(var.static_sta_brands)
  source                   = "../../../../../Devops/terraform/modules/storage-account"
  context                  = local.context
  domain                   = var.domain_name
  resource_group           = var.rg_infra
  account_name             = lower(substr(replace("${local.context.environment}sta${each.key}static${random_string.storage_suffix.result}", "-", ""), 0, 24))
  account_tier             = "Standard"
  account_replication_type = "LRS"
  enable_static_website    = true
  depends_on = [
    random_string.storage_suffix
  ]
}

module "automation-account" {
  source         = "../../../../../Devops/terraform/modules/automations/automation-account"
  context        = local.context
  domain         = var.domain_name
  resource_group = var.rg_infra
  tags           = local.tags
}

data "local_file" "script" {
  filename = "scripts/vm-scheduler.ps1"
}

module "automation-runbook" {
  source         = "../../../../../Devops/terraform/modules/automations/automation_runbook"
  context        = local.context
  domain         = var.domain_name
  resource_group = var.rg_infra


  runbook_list = {
    vm_scheduler = {
      name                    = "VM-Start-Stop-Scheduler"
      automation_account_name = module.automation-account.account_name
      description             = "VM Scheduler"
      runbook_type            = "PowerShellWorkflow"
      content                 = data.local_file.script.content
      log_progress            = true
      log_verbose             = false
    }
  }

  schedule_list = {
    schedule_stop = {
      automation_account_name = module.automation-account.account_name
      frequency               = "Week"
      interval                = 1
      timezone                = "Australia/Sydney"
      start_time              = "00:30:00+11:00"
      description             = "Schedule Run Every Week Days at 12:30 AM "
      week_days               = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    }

    schedule_start = {
      automation_account_name = module.automation-account.account_name
      frequency               = "Week"
      interval                = 1
      timezone                = "Australia/Sydney"
      start_time              = "08:00:00+11:00"
      description             = "Schedule Run Every Week Days at 8 AM "
      week_days               = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    }

  }

  job_schedule_list = {
    schedule_start = {
      automation_account_name = module.automation-account.account_name
      schedule_name           = "schedule_start"
      runbook_name            = "VM-Start-Stop-Scheduler"

      parameters = {
        subscription_id = data.azurerm_subscription.current.id
        tag_key         = "VMStartStopScheduler"
        tag_value       = "schedule_1"
        action          = "start"
      }
    }

    schedule_stop = {
      automation_account_name = module.automation-account.account_name
      schedule_name           = "schedule_stop"
      runbook_name            = "VM-Start-Stop-Scheduler"

      parameters = {
        subscription_id = data.azurerm_subscription.current.id
        tag_key         = "VMStartStopScheduler"
        tag_value       = "schedule_1"
        action          = "stop"
      }
    }

  }

  tags = local.tags
}
