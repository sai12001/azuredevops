locals {
  tags                = merge(var.resource_group.tags, var.tags)
  domain_name         = var.domain
  psql_server_name    = "${var.context.environment}-psql-${local.domain_name}-shared"
  psql_server_version = var.config.server_version
  psql_admin_name     = var.config.server_username
  psql_storage_mb     = var.config.server_storage_mb
  psql_sku            = var.config.server_sku
  # Diagnostic Settings Config
  log_workspace = {
    name                = "${var.context.environment}-logs-${var.context.product}-workspace-${var.context.location_abbr}"
    resource_group_name = "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
  }
  psql__diagnostic_log_categories = ["PostgreSQLLogs"]

}

data "azurerm_log_analytics_workspace" "law" {
  name                = local.log_workspace.name
  resource_group_name = local.log_workspace.resource_group_name
}

data "azurerm_key_vault" "key_vault" {
  name                = "${var.context.environment}-kv-${var.context.product}-${var.domain}-${var.context.location_abbr}"
  resource_group_name = "${var.context.environment}-rg-${var.context.product}-${var.domain}-shared-${var.context.location_abbr}"
}

resource "random_password" "admin_password" {
  length           = 16
  special          = true
  override_special = "/="
}

resource "azurerm_key_vault_secret" "secret_admin_password" {
  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = "psql-admin-password-${local.psql_server_name}"
  value        = random_password.admin_password.result
  lifecycle {
    ignore_changes = [
      key_vault_id
    ]
  }
}

resource "azurerm_key_vault_secret" "secret_admin_username" {
  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = "psql-admin-username-${local.psql_server_name}"
  value        = local.psql_admin_name
  lifecycle {
    ignore_changes = [
      key_vault_id
    ]
  }
}

resource "azurerm_postgresql_flexible_server" "flexible_server" {
  name                   = local.psql_server_name
  resource_group_name    = var.resource_group.name
  location               = var.resource_group.location
  version                = local.psql_server_version
  delegated_subnet_id    = var.psql_subnet_id
  private_dns_zone_id    = var.psql_dns_zone_id
  administrator_login    = local.psql_admin_name
  administrator_password = random_password.admin_password.result
  zone                   = "1"

  storage_mb = local.psql_storage_mb

  sku_name = local.psql_sku
  tags     = local.tags
}

resource "azurerm_key_vault_secret" "psql_fqdn" {
  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = "psql-dns-${local.psql_server_name}"
  value        = azurerm_postgresql_flexible_server.flexible_server.fqdn
  lifecycle {
    ignore_changes = [
      key_vault_id
    ]
  }
  depends_on = [
    azurerm_postgresql_flexible_server.flexible_server
  ]
}


resource "azurerm_key_vault_secret" "psql_ado_connectionstring" {
  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = "psql-connection-template-ado-${local.psql_server_name}"
  value        = "Server=${azurerm_postgresql_flexible_server.flexible_server.fqdn};Database={0};Port=5432;User Id=${local.psql_admin_name};Password=${random_password.admin_password.result};Ssl Mode=Require;Trust Server Certificate=true"
  lifecycle {
    ignore_changes = [
      key_vault_id
    ]
  }
  depends_on = [
    azurerm_postgresql_flexible_server.flexible_server
  ]
}

resource "azurerm_postgresql_flexible_server_database" "databases" {
  for_each  = { for db in var.databases : db.name => db }
  name      = each.key
  server_id = azurerm_postgresql_flexible_server.flexible_server.id
  collation = each.value.collation
  charset   = each.value.charset
}

#----------------------------------------------------------------------------------------------------------
#Postgres SQL Server Diagnostic Setting
#----------------------------------------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "postgresql_flexible_server_diags" {
  name                       = format("%s-diags", azurerm_postgresql_flexible_server.flexible_server.name)
  target_resource_id         = azurerm_postgresql_flexible_server.flexible_server.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.law.id
  dynamic "log" {
   for_each = local.psql__diagnostic_log_categories
   content {
     category = log.value
     retention_policy {
      days    = var.log_analytics_retention
       enabled = false
     }
   }
  }
  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }

  }
  depends_on = [
    azurerm_postgresql_flexible_server.flexible_server
  ]
}
