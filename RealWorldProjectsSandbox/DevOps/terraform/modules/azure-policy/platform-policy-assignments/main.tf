#Data sources
data "azurerm_policy_set_definition" "platform_services_policy_initiative" {
  name                      = var.policy_initiative_name
  management_group_name     = var.management_group_name
}

data "azurerm_management_group" "platform_services_management_group" {
  name                      = var.management_group_name
}

#Policy Assignment
resource "azurerm_management_group_policy_assignment" "platform_services_assignment" {
  name                      = var.policy_initiative_name
  policy_definition_id      = data.azurerm_policy_set_definition.platform_services_policy_initiative.id
  management_group_id       = data.azurerm_management_group.platform_services_management_group.id

  identity {
    type                    = "SystemAssigned"
  }
  location                  = "australiaeast"
}