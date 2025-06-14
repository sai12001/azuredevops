output "application_insights" {
  description = "The values need to pass to downstream for logging"
  value = {
    instrumentation_key = azurerm_application_insights.app_insights.instrumentation_key
    app_id              = azurerm_application_insights.app_insights.app_id
    id                  = azurerm_application_insights.app_insights.id
    connection_string   = azurerm_application_insights.app_insights.connection_string
  }
}
