output "workspace_url" {
  value = azurerm_databricks_workspace.az_databricks_workspace.workspace_url
}

output "workspace_id" {
  value = azurerm_databricks_workspace.az_databricks_workspace.id
}

output "cluster_id" {
  value = databricks_cluster.cluster.*.id
}