locals {
  tags = merge(var.resource_group.tags, var.tags)
  hub_tags = merge(local.tags, {
    "service" = "Microsoft.Network/vpnGateways/vpnConnections"
  })
}

resource "azurerm_virtual_wan" "global_wan" {
  name                = var.wan_name
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  tags                = local.tags
}

resource "azurerm_virtual_hub" "wan_hubs" {
  for_each            = var.wan_hubs
  name                = each.key
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  virtual_wan_id      = azurerm_virtual_wan.global_wan.id
  sku                 = "Standard"
  address_prefix      = each.value.address_prefix
  tags                = local.hub_tags
  depends_on = [
    azurerm_virtual_wan.global_wan
  ]
}

resource "azurerm_virtual_hub_connection" "hub_connections" {
  for_each                  = var.hub_connections
  name                      = each.key
  virtual_hub_id            = azurerm_virtual_hub.wan_hubs[each.value.hub_name].id
  remote_virtual_network_id = each.value.vnet_id
  routing {
    associated_route_table_id = var.default_route_table_id
    propagated_route_table {
      labels = [ "default" ]
#For Isolated VNET change the labels value to "NONE" and associate a new route table instead of the default route table
    }
  }
  depends_on = [
    azurerm_virtual_hub.wan_hubs
  ]
}


resource "azurerm_virtual_hub_route_table" "route_tables" {
  for_each       = var.hub_route_tables
  name           = each.key
  virtual_hub_id = azurerm_virtual_hub.wan_hubs[each.value.hub_name].id
  labels         = each.value.labels

  route {
    name              = each.value.route.name
    destinations_type = each.value.route.destinations_type
    destinations      = each.value.route.destinations
    next_hop_type     = each.value.route.next_hop_type
    next_hop          = azurerm_virtual_hub_connection.hub_connections[each.value.route.connection_name].id
  }
  depends_on = [
    azurerm_virtual_hub_connection.hub_connections
  ]
}
