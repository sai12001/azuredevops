output "aks_cluster_config" {
  description = "The configuration information for aks required for downstream"
  value = {
    name           = local.cluster_name
    resource_group = azurerm_resource_group.rg_aks.name

  }

}
