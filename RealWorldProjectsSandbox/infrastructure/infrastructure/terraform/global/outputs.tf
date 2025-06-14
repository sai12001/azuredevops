output "vmss_agent_pwd" {
    value = module.vmss_agents.vmss_password
    sensitive = true 
}