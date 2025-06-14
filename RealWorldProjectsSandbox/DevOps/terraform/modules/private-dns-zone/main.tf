locals {
  tags               = merge(var.resource_group.tags, var.tags)
  internal_zone_name = var.context.environment == "prd" ? "internal.blackstream.com.au" : "internal.${var.context.environment}.blackstream.com.au"
  psql_zone_name     = var.context.environment == "prd" ? "shared.postgres.database.azure.com" : "shared.${var.context.environment}.postgres.database.azure.com"
  dns_zones          = var.privatelink_dns_zones
}

resource "azurerm_private_dns_zone" "internal" {
  count               = var.provision_internal_zone ? 1 : 0
  name                = local.internal_zone_name
  resource_group_name = var.resource_group.name
  tags                = local.tags
}

resource "azurerm_private_dns_zone" "priavte_link_zones" {
  for_each            = { for zone in local.dns_zones : zone => local.private_zone_maps[zone] }
  name                = each.value
  resource_group_name = var.resource_group.name
  tags                = local.tags
}

resource "azurerm_private_dns_zone" "private_psql_zone" {
  count               = var.provision_psql_zone ? 1 : 0
  name                = local.psql_zone_name
  resource_group_name = var.resource_group.name
  tags                = local.tags
}

data "azurerm_virtual_network" "shared_vnet" {
  name                = var.vnet_config.name
  resource_group_name = var.vnet_config.resource_group
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_link_paas" {
  for_each              = { for zone in local.dns_zones : zone => local.private_zone_maps[zone] }
  name                  = replace("privatelins-zone-link-${each.key}", "_", "-")
  private_dns_zone_name = each.value
  virtual_network_id    = data.azurerm_virtual_network.shared_vnet.id
  resource_group_name   = var.resource_group.name
  tags                  = local.tags
  lifecycle {
    ignore_changes = [virtual_network_id]
  }
  depends_on = [
    azurerm_private_dns_zone.priavte_link_zones
  ]
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_link_internal" {
  count                 = var.provision_internal_zone ? 1 : 0
  name                  = "internal-dns-zone"
  private_dns_zone_name = azurerm_private_dns_zone.internal[0].name
  virtual_network_id    = data.azurerm_virtual_network.shared_vnet.id
  resource_group_name   = var.resource_group.name
  tags                  = local.tags
  lifecycle {
    ignore_changes = [virtual_network_id]
  }
  depends_on = [
    azurerm_private_dns_zone.internal
  ]
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_link_psql" {
  count                 = var.provision_psql_zone ? 1 : 0
  name                  = "psql-dns-zone"
  private_dns_zone_name = azurerm_private_dns_zone.private_psql_zone[0].name
  virtual_network_id    = data.azurerm_virtual_network.shared_vnet.id
  resource_group_name   = var.resource_group.name
  tags                  = local.tags
  lifecycle {
    ignore_changes = [virtual_network_id]
  }
  depends_on = [
    azurerm_private_dns_zone.private_psql_zone
  ]
}
