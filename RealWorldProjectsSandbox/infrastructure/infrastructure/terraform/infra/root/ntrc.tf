
locals {
  ntrc_key_vault_name      = "${var.environment}-kv-${var.product}-ntrc-${var.location_abbr}"
  ntrc_resource_group_name = "${var.environment}-rg-${var.product}-ntrc-shared-${var.location_abbr}"
}

module "rg_ntrc" {
  count               = var.enable_ntrc ? 1 : 0
  source              = "../../../../../DevOps/terraform/modules/resource-group"
  context             = local.context
  belong_to_team      = var.team_name
  resource_group_name = local.ntrc_resource_group_name
  tags = merge(local.tags, {
    purpose = "NTRC"
    access  = "Restricted"
    domain  = "ntrc"
  })
  prevent_destroy = true
}

module "vnet_ntrc" {
  count                   = var.enable_ntrc ? 1 : 0
  source                  = "../../../../../DevOps/terraform/modules/virtual-network"
  vnet                    = var.vnet_ntrc
  context                 = local.context
  resource_group          = module.rg_ntrc[0].resource_group
  environment             = var.environment
  log_analytics_retention = var.log_analytics_retention
  depends_on = [
    module.rg_ntrc
  ]
  tags = local.tags
}


module "ntrc_key_vault" {
  source                  = "../../../../../DevOps/terraform/modules/key-vault"
  resource_group          = module.rg_ntrc[0].resource_group
  key_vault_name          = local.ntrc_key_vault_name
  context                 = local.context
  environment             = var.environment
  tags                    = local.tags
  log_analytics_retention = var.log_analytics_retention
  depends_on = [
    module.rg_infra
  ]
}

module "sqlmi_instance_ntrc" {
  source         = "../../../../../DevOps/terraform/modules/sql-managed-instance"
  context        = local.context
  instance_name  = var.ntrc_sql_mi.instance_name
  resource_group = module.rg_ntrc[0].resource_group
  vnet_config    = module.vnet_ntrc[0].vnet_config

  administrator_login = var.ntrc_sql_mi.administrator_login
  db_user             = var.ntrc_sql_mi.db_user

  collation            = var.ntrc_sql_mi.collation
  vcores               = var.ntrc_sql_mi.vcores
  storage_account_type = var.ntrc_sql_mi.storage_account_type
  storage_size_in_gb   = var.ntrc_sql_mi.storage_size_in_gb

  proxy_override = var.ntrc_sql_mi.proxy_override
  timezone_id    = var.ntrc_sql_mi.timezone_id
  license_type   = var.ntrc_sql_mi.license_type
  sku_name       = var.ntrc_sql_mi.sku_name

  public_data_endpoint_enabled = var.ntrc_sql_mi.public_data_endpoint_enabled
  subnet_name                  = var.ntrc_sql_mi.subnet_name
  network_security_group_rules = var.ntrc_sql_mi.network_security_group_rules

  key_vault = module.ntrc_key_vault.key_vault

  log_analytics_retention = var.log_analytics_retention

  depends_on = [
    module.vnet_ntrc,
    module.ntrc_key_vault
  ]
}
