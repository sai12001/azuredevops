output "vnet_config" {
  value = {
    name           = var.vnet.name
    resource_group = var.resource_group.name
  }
}
