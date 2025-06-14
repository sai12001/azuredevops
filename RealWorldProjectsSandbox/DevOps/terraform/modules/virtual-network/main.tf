locals {
  tags = merge(var.resource_group.tags, var.tags)

  vnet = defaults(var.vnet, {
    subnets = {
      delegation = {
        name = "placeholder"
        service_delegation = {
          name    = "placeholder"
          actions = ""
        }
      }
      service_endpoints = ""
    }
  })
  subnets = { for subnet in local.vnet.subnets : subnet.name => subnet }
  # Diagnostic Settings Config
  log_workspace = {
    name                = "${var.context.environment}-logs-${var.context.product}-workspace-${var.context.location_abbr}"
    resource_group_name = "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
  }
  virtual_network_diagnostic_log_categories = ["VMProtectionAlerts"]
}

data "azurerm_log_analytics_workspace" "law" {
  name                = local.log_workspace.name
  resource_group_name = local.log_workspace.resource_group_name
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet.name
  address_space       = var.vnet.address_space
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  tags                = local.tags
}

resource "azurerm_subnet" "subnets" {
  for_each             = local.subnets
  name                 = each.key
  resource_group_name  = var.resource_group.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = each.value.prefixes

  dynamic "delegation" {
    for_each = each.value.delegation == {} || each.value.delegation == null ? [] : [1]
    content {
      name = each.value.delegation.name
      service_delegation {
        name    = each.value.delegation.service_delegation.name
        actions = each.value.delegation.service_delegation.actions
      }
    }
  }

  service_endpoints = each.value.service_endpoints

  depends_on = [
    azurerm_virtual_network.vnet
  ]
}
/*----------------------------------------------------------------------------------------------------------
Virtual Network Diagnostic Settings
----------------------------------------------------------------------------------------------------------*/

resource "azurerm_monitor_diagnostic_setting" "vnet_diags" {
  name                           = format("%s-diags", azurerm_virtual_network.vnet.name)
  target_resource_id             = azurerm_virtual_network.vnet.id
  log_analytics_workspace_id     = data.azurerm_log_analytics_workspace.law.id
/*----------------------------------------------------------------------------------------------------------
Log types to enable:
- VMProtectionAlerts
----------------------------------------------------------------------------------------------------------*/

  dynamic "log" {
    for_each = local.virtual_network_diagnostic_log_categories
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
      days    = var.log_analytics_retention
      enabled = true
    }
  }

  depends_on = [
    azurerm_virtual_network.vnet
    ]
}
