output "log_workspace" {
  description = "the details for log workspaces"
  value = {
    id   = azurerm_log_analytics_workspace.log_workspace.id
    name = azurerm_log_analytics_workspace.log_workspace.name
  }
}
