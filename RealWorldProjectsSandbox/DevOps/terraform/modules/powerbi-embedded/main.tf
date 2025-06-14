locals {
  tags     = merge(var.resource_group.tags, var.tags)
  pbi_name = "${var.context.environment}powerbi${var.context.product}embedded"
}

#---------------------------------------
# PowerBI Embedded Resource
#---------------------------------------
resource "azurerm_powerbi_embedded" "powerbi" {
  name                = local.pbi_name
  location            = var.location
  resource_group_name = var.resource_group.name
  sku_name            = var.sku_name
  administrators      = var.administrators
  mode                = var.pbi_mode
  tags                = local.tags
}