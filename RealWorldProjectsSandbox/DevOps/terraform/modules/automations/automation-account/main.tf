resource "azurerm_automation_account" "account" {
  name                = "${var.context.environment}-aa-${var.context.product}-${var.domain}"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  sku_name            = var.sku_name

  identity {
    type         = var.identity_type
    identity_ids = var.identity_type == "SystemAssigned" ? null : var.identity_ids
  }

  tags = var.tags
}