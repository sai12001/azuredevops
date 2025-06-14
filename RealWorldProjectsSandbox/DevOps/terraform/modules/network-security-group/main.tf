locals {
  tags = merge(var.resource_group.tags, var.tags)
  custom_rules = defaults(var.custom_rules, {
  })
  # Diagnostic Settings Config
  log_workspace = {
    name                = "${var.context.environment}-logs-${var.context.product}-workspace-${var.context.location_abbr}"
    resource_group_name = "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
  }  
  nsg_diagnostic_log_categories             = ["NetworkSecurityGroupEvent", "NetworkSecurityGroupRuleCounter"]


}
#############################
# Data Sources #
#############################
data "azurerm_log_analytics_workspace" "law" {
  name                = local.log_workspace.name
  resource_group_name = local.log_workspace.resource_group_name
}

# IP Address
# Service Tags like SQL, Storage, etc
# Virtualnetworks
# Destination application security groups [TBD]



resource "azurerm_network_security_group" "nsg" {
  name                = var.security_group_name
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  tags                = local.tags
}

#############################
# predefined security rules #
#############################

resource "azurerm_network_security_rule" "predefined_rules" {
  for_each                     = { for rule in var.predefined_rules : rule.name => rule }
  resource_group_name          = var.resource_group.name
  network_security_group_name  = azurerm_network_security_group.nsg.name
  name                         = each.value.name
  priority                     = local.rules[each.value.name].priority
  direction                    = local.rules[each.value.name].direction
  access                       = local.rules[each.value.name].access
  protocol                     = local.rules[each.value.name].protocol
  source_port_range            = local.rules[each.value.name].source_port_range == "*" ? "*" : null
  source_port_ranges           = local.rules[each.value.name].source_port_range == "*" ? null : split(",", local.rules[each.value.name].source_port_range)
  destination_port_range       = local.rules[each.value.name].destination_port_range
  description                  = local.rules[each.value.name].description
  source_address_prefix        = local.rules[each.value.name].source_address_prefix != null ? local.rules[each.value.name].source_address_prefix : each.value.source_address_prefix != null ? each.value.source_address_prefix : null
  source_address_prefixes      = local.rules[each.value.name].source_address_prefixes != null ? local.rules[each.value.name].source_address_prefixes : each.value.source_address_prefixes != null ? each.value.source_address_prefixes : null
  destination_address_prefix   = local.rules[each.value.name].destination_address_prefix != null ? local.rules[each.value.name].destination_address_prefix : each.value.destination_address_prefix != null ? each.value.destination_address_prefix : null
  destination_address_prefixes = local.rules[each.value.name].destination_address_prefixes != null ? local.rules[each.value.name].destination_address_prefixes : each.value.destination_address_prefixes != null ? each.value.destination_address_prefixes : null
}

#############################
# customized security rules #
#############################

resource "azurerm_network_security_rule" "custom_rules" {
  for_each                     = { for rule in var.custom_rules : rule.name => rule }
  resource_group_name          = var.resource_group.name
  network_security_group_name  = azurerm_network_security_group.nsg.name
  name                         = each.value.name
  priority                     = each.value.priority
  direction                    = each.value.direction
  access                       = each.value.access
  protocol                     = each.value.protocol
  source_port_range            = each.value.source_port_range == "*" ? "*" : null
  source_port_ranges           = each.value.source_port_range == "*" ? null : split(",", local.rules[each.value.name].source_port_range)
  destination_port_range       = each.value.destination_port_range
  description                  = each.value.description
  source_address_prefix        = each.value.source_address_prefix != null && each.value.source_address_prefixes == null ? each.value.source_address_prefix : null
  source_address_prefixes      = each.value.source_address_prefix == null && each.value.source_address_prefixes != null ? each.value.source_address_prefixes : null
  destination_address_prefix   = each.value.destination_address_prefix != null && each.value.destination_address_prefixes == null ? each.value.destination_address_prefix : null
  destination_address_prefixes = each.value.destination_address_prefixes != null && each.value.destination_address_prefix == null ? each.value.destination_address_prefixes : null
}

#----------------------------------------------------------------------------------------------------------
# NSG Diagnostic Setting
#----------------------------------------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "nsg_diags" {
  name                       = format("%s-diags", azurerm_network_security_group.nsg.name)
  target_resource_id         = azurerm_network_security_group.nsg.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.law.id
  #Placeholder to choose log categories
  dynamic "log" {
    for_each = local.nsg_diagnostic_log_categories
    content {
      category = log.value
      retention_policy {
        days    = var.log_analytics_retention
        enabled = true
      }
    }
  }
  depends_on = [
    azurerm_network_security_group.nsg
  ]
}
