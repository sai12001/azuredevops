locals {
  tags = merge(var.resource_group.tags, var.tags)
  hub_tags = merge(local.tags, {
    "service" = "Microsoft.Network/vpnGateways/vpnConnections"
  })
  # Diagnostic Settings Config
  log_workspace = {
    name                = "${var.context.environment}-logs-${var.context.product}-workspace-${var.context.location_abbr}"
    resource_group_name = "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
  }
  azfw_diagnostic_log_categories  = ["AzureFirewallNetworkRule" ]
}

# Get Virtual Hub Data
data "azurerm_virtual_hub" "virtual_hub" {
  name                = "WAN-Hub-Melbourne"
  resource_group_name = var.resource_group.name
}

data "azurerm_log_analytics_workspace" "law" {
  name                = local.log_workspace.name
  resource_group_name = local.log_workspace.resource_group_name
}

# Azure Firewall Deployment
resource "azurerm_firewall" "azfw" {
  name                = lower("${var.environment}-fw-${var.firewall_name}")
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  sku_name            = "AZFW_Hub"
  sku_tier            = var.firewall_sku_tier
  firewall_policy_id  = var.firewall_policy_id
  zones               = var.firewall_availibility_zones
  #dns_servers         = var.firewall_dns_servers
  #private_ip_ranges   = var.firewall_private_ip_ranges
  virtual_hub {
       virtual_hub_id = data.azurerm_virtual_hub.virtual_hub.id
  }

}

#----------------------------------------------------------------------------------------------------------
# Azure Firewall Diagnostic Settings
#----------------------------------------------------------------------------------------------------------# 
resource "azurerm_monitor_diagnostic_setting" "azfw_diag" {
  name                          = format("%s-diags", azurerm_firewall.azfw.name)
  target_resource_id            = azurerm_firewall.azfw.id
  log_analytics_workspace_id    = data.azurerm_log_analytics_workspace.law.id

  dynamic "log" {
   for_each = local.azfw_diagnostic_log_categories
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
}