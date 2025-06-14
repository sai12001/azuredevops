output "storage_account" {
  description = "TODO"
  value = {
    connection_string = azurerm_storage_account.storage_account.primary_connection_string
    name              = var.account_name
  }
  sensitive = true
}
