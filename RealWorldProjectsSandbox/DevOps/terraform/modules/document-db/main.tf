locals {
  tags                   = merge(var.resource_group.tags, var.tags)
  domain_name            = var.domain
  cosmos_db_account_name = "${var.context.environment}-docdb-${var.context.product}-${var.cosmos_name}-${var.context.location_abbr}"
  cosmosdb_account = defaults(var.cosmosdb_account, {
    consistency_level               = "Session"
    offer_type                      = "Standard"
    kind                            = "GlobalDocumentDB"
    primary_location_zone_redundant = false
  })
  cosmosdb_sqldbs = defaults(var.cosmosdb_sqldbs, {
    max_throughput = 1000,
    containers = {
      indexing_mode  = "consistent"
      max_throughput = 1000,
      included_paths = "/*"
      excluded_paths = "/\"_etag\"/?"
      unique_keys    = ""
      default_ttl    = -1
  } })
  sql_databases = { for db in local.cosmosdb_sqldbs : db.name => {
    max_throughput = db.max_throughput
  } }

  sql_containers = flatten([for db in local.cosmosdb_sqldbs : [
    for container in db.containers : {
      db_name   = db.name
      container = container
    }
  ]])

  sql_triggers = flatten([for container in local.sql_containers : [
    for trigger in container.container.triggers : {
      db_name        = container.db_name
      container_name = container.container.name
      trigger        = trigger
    }
  ]])

  sql_stored_procedures = flatten([for container in local.sql_containers : [
    for sp in container.container.stored_procedures : {
      db_name          = container.db_name
      container_name   = container.container.name
      stored_procedure = sp
    }
  ]])
  sql_functions = flatten([for container in local.sql_containers : [
    for function in container.container.functions : {
      db_name        = container.db_name
      container_name = container.container.name
      function       = function
    }
  ]])

  domain_subnets = { for subnet in data.azurerm_subnet.subnets : subnet.name => subnet if length(regexall("subnet-${local.domain_name}", subnet.name)) > 0 }
  # Diagnostic Settings
  log_workspace = {
    name                = "${var.context.environment}-logs-${var.context.product}-workspace-${var.context.location_abbr}"
    resource_group_name = "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
  }
  cosmosdb_diagnostic_log_categories = ["DataPlaneRequests", "ControlPlaneRequests", "TableApiRequests", "QueryRuntimeStatistics"]


}

data "azurerm_virtual_network" "shared_vnet" {
  name                = var.vnet_config.name
  resource_group_name = var.vnet_config.resource_group
}

data "azurerm_subnet" "subnets" {
  for_each             = toset(var.subnets)
  name                 = each.value
  virtual_network_name = data.azurerm_virtual_network.shared_vnet.name
  resource_group_name  = data.azurerm_virtual_network.shared_vnet.resource_group_name
}

data "azurerm_log_analytics_workspace" "law" {
  name                = local.log_workspace.name
  resource_group_name = local.log_workspace.resource_group_name
}

resource "azurerm_cosmosdb_account" "db_account" {
  name                = local.cosmos_db_account_name
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  offer_type          = local.cosmosdb_account.offer_type
  kind                = local.cosmosdb_account.kind
  tags                = local.tags

  enable_automatic_failover = true

  consistency_policy {
    consistency_level       = local.cosmosdb_account.consistency_level
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }

  geo_location {
    location          = local.cosmosdb_account.primary_location
    failover_priority = 0
    zone_redundant    = local.cosmosdb_account.primary_location_zone_redundant
  }

  dynamic "geo_location" {
    for_each = var.extra_cosmosdb_az_regions
    content {
      location          = geo_location.value.location
      failover_priority = geo_location.value.priority
      zone_redundant    = geo_location.value.zone_redundant
    }
  }
  is_virtual_network_filter_enabled = true

  dynamic "virtual_network_rule" {
    for_each = local.domain_subnets
    content {
      id                                   = virtual_network_rule.value.id
      ignore_missing_vnet_service_endpoint = false
    }
  }
  # HARD CODE IT, AS IT WILL NOT CHANGE
  # Azure Portal, Azure Data Center IPs, Amused Group Office IP
  ip_range_filter = "0.0.0.0,104.42.195.92,40.76.54.131,52.176.6.30,52.169.50.45,52.187.184.26,139.130.32.10"
}

resource "azurerm_private_endpoint" "docdb_private_endpoints" {
  count               = var.privatelink == null ? 0 : 1
  name                = lower("link-${local.cosmos_db_account_name}")
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  subnet_id           = var.privatelink.subnet_id

  private_service_connection {
    private_connection_resource_id = azurerm_cosmosdb_account.db_account.id
    name                           = lower(local.cosmos_db_account_name)
    subresource_names              = ["Sql"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "private-dns"
    private_dns_zone_ids = [var.privatelink.private_dns_zone_id]
  }
}


resource "azurerm_cosmosdb_sql_database" "databases" {
  for_each            = local.sql_databases
  name                = each.key
  resource_group_name = var.resource_group.name
  account_name        = azurerm_cosmosdb_account.db_account.name
  autoscale_settings {
    max_throughput = each.value.max_throughput
  }
  depends_on = [
    azurerm_cosmosdb_account.db_account
  ]
}

resource "azurerm_cosmosdb_sql_container" "containers" {
  for_each              = { for container in local.sql_containers : "${container.db_name}-${container.container.name}" => container }
  name                  = each.value.container.name
  resource_group_name   = var.resource_group.name
  account_name          = azurerm_cosmosdb_account.db_account.name
  database_name         = each.value.db_name
  partition_key_path    = each.value.container.partition_key_path
  partition_key_version = 1

  autoscale_settings {
    max_throughput = each.value.container.max_throughput
  }

  indexing_policy {
    indexing_mode = "consistent"

    dynamic "included_path" {
      for_each = each.value.container.included_paths
      content {
        path = included_path.value
      }
    }
    dynamic "excluded_path" {
      for_each = each.value.container.excluded_paths
      content {
        path = excluded_path.value
      }
    }
  }

  unique_key {
    paths = each.value.container.unique_keys
  }

  default_ttl = each.value.container.default_ttl
  lifecycle {
    ignore_changes = [
      unique_key
    ]
  }

  depends_on = [
    azurerm_cosmosdb_sql_database.databases
  ]
}


resource "azurerm_cosmosdb_sql_trigger" "container_sql_triggers" {
  for_each     = { for trigger in local.sql_triggers : "${trigger.db_name}-${trigger.container_name}-${trigger.trigger.name}" => trigger }
  name         = each.value.trigger.name
  container_id = azurerm_cosmosdb_sql_container.containers["${each.value.db_name}-${each.value.container_name}"].id
  body         = each.value.trigger.body
  operation    = each.value.trigger.operation
  type         = each.value.trigger.type
  depends_on = [
    azurerm_cosmosdb_sql_container.containers
  ]
}

resource "azurerm_cosmosdb_sql_function" "container_sql_functions" {
  for_each     = { for fn in local.sql_functions : "${fn.db_name}-${fn.container_name}-${fn.function.name}" => fn }
  name         = each.value.function.name
  container_id = azurerm_cosmosdb_sql_container.containers["${each.value.db_name}-${each.value.container_name}"].id
  body         = each.value.function.body
  depends_on = [
    azurerm_cosmosdb_sql_container.containers
  ]
}

resource "azurerm_cosmosdb_sql_stored_procedure" "container_sql_sps" {
  for_each            = { for sp in local.sql_stored_procedures : "${sp.db_name}-${sp.container_name}-${sp.stored_procedure.name}" => sp }
  name                = each.value.stored_procedure.name
  resource_group_name = var.resource_group.name
  account_name        = azurerm_cosmosdb_account.db_account.name
  database_name       = each.value.db_name
  container_name      = each.value.container_name
  body                = each.value.stored_procedure.body
  depends_on = [
    azurerm_cosmosdb_sql_container.containers
  ]
}



data "azurerm_key_vault" "key_vault" {
  name                = "${var.context.environment}-kv-${var.context.product}-${var.domain}-${var.context.location_abbr}"
  resource_group_name = "${var.context.environment}-rg-${var.context.product}-${var.domain}-shared-${var.context.location_abbr}"
}

resource "azurerm_key_vault_secret" "docdb_secret" {
  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = "docdb-connection-string-${local.cosmos_db_account_name}"
  value        = azurerm_cosmosdb_account.db_account.connection_strings[0]
  lifecycle {
    ignore_changes = [
      key_vault_id
    ]
  }
}

resource "azurerm_monitor_diagnostic_setting" "cosmosdb_diags" {
  name                       = format("%s-diags", azurerm_cosmosdb_account.db_account.name)
  target_resource_id         = azurerm_cosmosdb_account.db_account.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.law.id
  #Placeholder to choose log categories
  dynamic "log" {
    for_each = local.cosmosdb_diagnostic_log_categories
    content {
      category = log.value
      retention_policy {
        days    = var.log_analytics_retention
        enabled = true
      }
    }
  }
  metric {
    category = "Requests"

    retention_policy {
      enabled = false
    }

  }
  lifecycle {
    ignore_changes = [log, log_analytics_destination_type]
  }
  depends_on = [
    azurerm_cosmosdb_account.db_account
  ]
}
