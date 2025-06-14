output "windows_virtual_machine_ids" {
  description = "The resource id's of all Windows Virtual Machine."
  value       = azurerm_virtual_machine.win_vm.*.id
}