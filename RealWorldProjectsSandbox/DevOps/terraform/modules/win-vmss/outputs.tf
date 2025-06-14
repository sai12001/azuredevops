output "vmss_password" {
    value = random_password.vm_password.result
}