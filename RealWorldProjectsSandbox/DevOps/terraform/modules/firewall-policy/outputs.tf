output "policy_id" {
  description = "ID of the Firewall Policy applied to this Firewall."
  value =  azurerm_firewall_policy.fw_policy.id
}