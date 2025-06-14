output "databricks_id" {
value = azurerm_policy_definition.deny_azure_databricks.id
description           = "The Deny Databrick policy definition id."
}
output "eventhub_id" {
value = azurerm_policy_definition.deny_azure_eventhub.id
description           = "The Deny Eventhub policy definition id."
}