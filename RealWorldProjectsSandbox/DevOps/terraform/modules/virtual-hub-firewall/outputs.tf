output "fw_private_ip" {
  description = "The Private IP Address of the Azure Firewall."
  value =  azurerm_firewall.azfw.virtual_hub[0].private_ip_address
}
output "fw_public_ip" {
  description = "The Public IP Address of the Azure Firewall."
  value =  azurerm_firewall.azfw.virtual_hub[0].public_ip_addresses
}