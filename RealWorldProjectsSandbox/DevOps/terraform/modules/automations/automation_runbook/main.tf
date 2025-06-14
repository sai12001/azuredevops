
resource "azurerm_automation_runbook" "runbook" {
  for_each                = var.runbook_list
  name                    = each.value.name
  location                = var.resource_group.location
  resource_group_name     = var.resource_group.name
  automation_account_name = each.value.automation_account_name
  log_verbose             = each.value.log_verbose
  log_progress            = each.value.log_progress
  description             = each.value.description
  runbook_type            = each.value.runbook_type

  content = each.value.content
  tags    = var.tags
}