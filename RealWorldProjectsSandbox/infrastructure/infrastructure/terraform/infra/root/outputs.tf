output "shared_vnet_config" {
  description = "vnet configuration for shared vnet"
  value       = module.vnet_shared.vnet_config
}

output "shared_infra_rg" {
  description = "share infra rg"
  value = module.rg_infra.resource_group
}
