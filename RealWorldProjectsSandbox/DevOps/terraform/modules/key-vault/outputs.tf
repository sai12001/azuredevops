output "key_vault" {
  value = {
    resource_group_name = azurerm_key_vault.key_vault.resource_group_name
    key_vault_name      = azurerm_key_vault.key_vault.name
  }
}
