locals {
  tags        = merge(var.resource_group.tags, var.tags)
  domain_name = var.domain

  eventhub_namespace = defaults(var.eventhub_namespace, {
    sku            = "Standard"
    capacity       = 1
    zone_redundant = false
  })
  eventhub_namespace_name = "${var.context.environment}-ehn-${var.context.product}-${local.domain_name}-${var.context.location_abbr}"

  eventhubs = defaults(var.eventhubs, {
    partition_count = 2
    retention_day   = 7
    consumer_groups = {
      name          = "$Default"
      user_metadata = local.domain_name
    }
    auth_rules = {
      listen = true
      send   = false
      manage = false
    }
  })

  addon_consumer_groups = defaults(var.consumer_groups, {
    user_metadata = local.domain_name
  })

  addon_auth_rules = defaults(var.auth_rules, {
    listen = true
    send   = false
    manage = false
  })

  eh_consumer_groups = flatten([for eh in local.eventhubs : [
    for cg in eh.consumer_groups : {
      domain_name   = eh.domain_name
      eventhub_name = eh.name
      name          = cg.name
      user_metadata = cg.user_metadata
    }
  ]])

  consumer_groups = { for cg in distinct(concat(local.addon_consumer_groups, local.eh_consumer_groups)) : "${cg.domain_name}-${cg.eventhub_name}-${cg.name}" => cg }

  eh_auth_rules = flatten([for eh in local.eventhubs : [
    for ar in eh.auth_rules : {
      domain_name   = eh.domain_name
      eventhub_name = eh.name
      name          = ar.name
      listen        = ar.listen
      send          = ar.send
      manage        = ar.manage
    }
  ]])
  auth_rules = { for ar in distinct(concat(local.addon_auth_rules, local.eh_auth_rules)) : "${ar.domain_name}-${ar.eventhub_name}-${ar.name}" => ar }
  # Diagnostic Settings
  log_workspace = {
    name                = "${var.context.environment}-logs-${var.context.product}-workspace-${var.context.location_abbr}"
    resource_group_name = "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
  }
  eventhubs_diagnostic_log_categories = ["OperationalLogs", "RuntimeAuditLogs", "ApplicationMetricsLogs"]
}

data "azurerm_log_analytics_workspace" "law" {
  name                = local.log_workspace.name
  resource_group_name = local.log_workspace.resource_group_name
}

resource "azurerm_eventhub_namespace" "eventhub_namespace" {
  count               = var.eventhub_namespace == null ? 0 : 1
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  name                = local.eventhub_namespace_name
  sku                 = local.eventhub_namespace.sku
  capacity            = local.eventhub_namespace.capacity
  zone_redundant      = local.eventhub_namespace.zone_redundant
  tags                = local.tags
}


resource "azurerm_eventhub" "eventhubs" {
  for_each            = { for eh in local.eventhubs : eh.name => eh }
  name                = each.key
  namespace_name      = "${var.context.environment}-ehn-${var.context.product}-${each.value.domain_name}-${var.context.location_abbr}"
  resource_group_name = "${var.context.environment}-rg-${var.context.product}-${each.value.domain_name}-shared-${var.context.location_abbr}"
  partition_count     = each.value.partition_count
  message_retention   = each.value.retention_day
}


resource "azurerm_eventhub_authorization_rule" "auth_rules" {
  for_each            = local.auth_rules
  name                = each.value.name
  namespace_name      = "${var.context.environment}-ehn-${var.context.product}-${each.value.domain_name}-${var.context.location_abbr}"
  resource_group_name = "${var.context.environment}-rg-${var.context.product}-${each.value.domain_name}-shared-${var.context.location_abbr}"
  eventhub_name       = each.value.eventhub_name
  listen              = each.value.listen
  send                = each.value.send
  manage              = each.value.manage
  depends_on = [
    azurerm_eventhub.eventhubs, azurerm_eventhub_consumer_group.consumer_groups
  ]
}

resource "azurerm_eventhub_consumer_group" "consumer_groups" {
  for_each            = local.consumer_groups
  name                = each.value.name
  namespace_name      = "${var.context.environment}-ehn-${var.context.product}-${each.value.domain_name}-${var.context.location_abbr}"
  resource_group_name = "${var.context.environment}-rg-${var.context.product}-${each.value.domain_name}-shared-${var.context.location_abbr}"
  eventhub_name       = each.value.eventhub_name
  user_metadata       = each.value.user_metadata
  depends_on = [
    azurerm_eventhub.eventhubs
  ]
}

data "azurerm_key_vault" "key_vault" {
  name                = "${var.context.environment}-kv-${var.context.product}-${local.domain_name}-${var.context.location_abbr}"
  resource_group_name = "${var.context.environment}-rg-${var.context.product}-${local.domain_name}-shared-${var.context.location_abbr}"
}

resource "azurerm_key_vault_secret" "secrets_connectionstrings" {
  for_each     = azurerm_eventhub_authorization_rule.auth_rules
  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = "eh-connection-string-${each.key}"
  value        = each.value.primary_connection_string
  lifecycle {
    ignore_changes = [
      key_vault_id
    ]
  }
  depends_on = [
    azurerm_eventhub_authorization_rule.auth_rules
  ]
}

#----------------------------------------------------------------------------------------------------------
# Event-Hubs Diagnostic Setting
#----------------------------------------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "eventhub_diags" {
  count                      = var.eventhub_namespace == null ? 0 : 1
  name                       = format("%s-diags", azurerm_eventhub_namespace.eventhub_namespace[0].name)
  target_resource_id         = azurerm_eventhub_namespace.eventhub_namespace[0].id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.law.id
  #Placeholder to choose log categories
  dynamic "log" {
    for_each = local.eventhubs_diagnostic_log_categories
    content {
      category = log.value
      retention_policy {
        days    = var.log_analytics_retention
        enabled = true
      }
    }
  }
  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }

  }
  lifecycle {
    ignore_changes = [log]
  }
  depends_on = [
    azurerm_eventhub_namespace.eventhub_namespace
  ]
}
