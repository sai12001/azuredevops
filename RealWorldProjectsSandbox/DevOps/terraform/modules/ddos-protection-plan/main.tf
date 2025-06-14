resource "azurerm_network_ddos_protection_plan" "ddos" {
  name                = lower("${var.environment}-ddos-protection-plan")
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  tags                = merge({ "ResourceName" = lower("${var.hub_vnet_name}-ddos-protection-plan") }, var.tags, )
}