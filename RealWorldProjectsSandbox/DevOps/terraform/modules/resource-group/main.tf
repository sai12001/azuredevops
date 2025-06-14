locals {
  tags = merge({
    provisioner = "terraform",
    environment = var.context.environment
    location    = var.context.location_abbr
    product     = var.context.product
    team        = var.belong_to_team
  }, var.tags)
}

resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.context.location
  tags     = local.tags
}

resource "azurerm_management_lock" "rg_prevent_delete" {
  count      = var.prevent_destroy ? 1 : 0
  name       = "delete prevention"
  scope      = azurerm_resource_group.resource_group.id
  lock_level = "CanNotDelete"
  notes      = "This Resource Group Cannot be delete"
}
