output "app_service_plan" {
  description = "The app service plan info for downstream"
  value = {
    id   = azurerm_service_plan.app_service_plan.id
    name = azurerm_service_plan.app_service_plan.name
  }
}
