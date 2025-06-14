locals {
  tags            = merge(var.resource_group.tags, var.tags)
  domain_name     = var.domain
  sql_server_name = "${var.context.environment}-sql-${local.domain_name}-shared"
  sql_admin_name  = var.sql_admin_name
  sql_version     = var.sql_version
  sql_databases = defaults(var.sql_databases, {
    read_scale     = false
    zone_redundant = false
  })

}

#---------------------------------------
# Data Sources
#---------------------------------------

data "azurerm_key_vault" "key_vault" {
  name                = "${var.context.environment}-kv-${var.context.product}-${var.domain}-${var.context.location_abbr}"
  resource_group_name = "${var.context.environment}-rg-${var.context.product}-${var.domain}-shared-${var.context.location_abbr}"
}

data "azurerm_virtual_network" "data_vnet" {
  name                = var.vnet_config.name
  resource_group_name = var.vnet_config.resource_group
}

data "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = var.vnet_config.resource_group
  virtual_network_name = var.vnet_config.name
}

#---------------------------------------
# Admin Credentials
#---------------------------------------

resource "random_password" "admin_password" {
  length           = 16
  special          = true
  override_special = "/="
}

resource "azurerm_key_vault_secret" "secret_admin_password" {
  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = "sql-admin-password-${local.sql_server_name}"
  value        = random_password.admin_password.result
  lifecycle {
    ignore_changes = [
      key_vault_id
    ]
  }
}

resource "azurerm_key_vault_secret" "secret_admin_username" {
  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = "sql-admin-username-${local.sql_server_name}"
  value        = local.sql_admin_name
  lifecycle {
    ignore_changes = [
      key_vault_id
    ]
  }
}

resource "azurerm_key_vault_secret" "sql_fqdn" {
  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = "sql-dns-${local.sql_server_name}"
  value        = azurerm_mssql_server.sql_server.fully_qualified_domain_name
  lifecycle {
    ignore_changes = [
      key_vault_id
    ]
  }
  depends_on = [
    azurerm_mssql_server.sql_server
  ]
}

resource "azurerm_key_vault_secret" "kv_secret_sqlmi_connection_string" {
  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = "sql-connectionstring-${local.sql_server_name}"
  value        = "Server=tcp:${azurerm_mssql_server.sql_server.fully_qualified_domain_name},1433;Persist Security Info=False;User ID=${local.sql_admin_name};Password=${random_password.admin_password.result};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  lifecycle {
    ignore_changes = [key_vault_id]
  }
  depends_on = [
    azurerm_mssql_server.sql_server
  ]
}

resource "azurerm_key_vault_secret" "kv_secret_sqlmi_connection_string_dbs" {
  for_each     = { for db in local.sql_databases : db.name => db }
  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = "sql-connectionstring-${local.sql_server_name}-${each.key}"
  value        = "Server=tcp:${azurerm_mssql_server.sql_server.fully_qualified_domain_name},1433;Persist Security Info=False;User ID=${local.sql_admin_name};Password=${random_password.admin_password.result};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;Initial Catalog=${each.key};"
  lifecycle {
    ignore_changes = [key_vault_id]
  }
  depends_on = [
    azurerm_mssql_server.sql_server
  ]
}

#---------------------------------------
# MS-SQL Server
#---------------------------------------

resource "azurerm_mssql_server" "sql_server" {
  name                          = local.sql_server_name
  resource_group_name           = var.resource_group.name
  location                      = var.resource_group.location
  version                       = local.sql_version
  administrator_login           = local.sql_admin_name
  administrator_login_password  = random_password.admin_password.result
  tags                          = local.tags
  public_network_access_enabled = var.public_network_access_enabled

  lifecycle {
    prevent_destroy = true
  }
}

#---------------------------------------
# Databases
#---------------------------------------

resource "azurerm_mssql_database" "databases" {
  for_each       = { for db in local.sql_databases : db.name => db }
  name           = each.value.name
  server_id      = azurerm_mssql_server.sql_server.id
  collation      = each.value.collation
  license_type   = each.value.license_type
  max_size_gb    = each.value.max_size_gb
  read_scale     = each.value.read_scale
  sku_name       = each.value.sku_name
  zone_redundant = each.value.zone_redundant

  tags = local.tags

  depends_on = [
    azurerm_mssql_server.sql_server
  ]

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      max_size_gb,
      sku_name
    ]
  }
}

#---------------------------------------
# SQL Private endpoint
#---------------------------------------

resource "azurerm_private_endpoint" "sql_private_endpoints" {
  name                = lower("link-${local.sql_server_name}")
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  subnet_id           = data.azurerm_subnet.subnet.id

  private_service_connection {
    private_connection_resource_id = azurerm_mssql_server.sql_server.id
    name                           = lower(local.sql_server_name)
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "private-dns"
    private_dns_zone_ids = [var.privatelink_private_dns_zone_id]
  }

  lifecycle {
    ignore_changes = [subnet_id]
  }
}
