output "resource_group" {
  description = "The resource group information needed for downstream"
  value = {
    location      = azurerm_resource_group.resource_group.location
    name          = azurerm_resource_group.resource_group.name
    location_abbr = var.context.location_abbr
    tags          = local.tags
  }
}
