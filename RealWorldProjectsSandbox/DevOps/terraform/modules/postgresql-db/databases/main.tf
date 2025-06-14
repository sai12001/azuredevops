locals {
  tags             = merge(var.resource_group.tags, var.tags)
  domain_name      = var.domain
  psql_server_name = "${var.context.environment}-psql-${local.domain_name}-shared"
  psql_server_rg   = "${var.context.environment}-rg-${var.context.product}-${local.domain_name}-shared-${var.context.location_abbr}"
}

data "azurerm_postgresql_flexible_server" "flexible_server" {
  name                = local.psql_server_name
  resource_group_name = local.psql_server_rg
}

resource "azurerm_postgresql_flexible_server_database" "databases" {
  for_each  = { for db in var.databases : db.name => db }
  name      = each.key
  server_id = data.azurerm_postgresql_flexible_server.flexible_server.id
  collation = each.value.collation
  charset   = each.value.charset
}
