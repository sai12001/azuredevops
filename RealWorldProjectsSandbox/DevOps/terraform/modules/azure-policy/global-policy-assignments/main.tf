##Policy Assignment

resource "azurerm_management_group_policy_assignment" "global_assignment" {
  name                      = var.policy_initiative_name
  policy_definition_id      = var.policy_initiative_id
  management_group_id       = var.global_management_group_id
}