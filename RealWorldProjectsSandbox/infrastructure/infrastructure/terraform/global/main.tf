locals {
  context = {
    product       = var.product
    environment   = var.environment
    location      = var.location
    domain        = var.domain_name
    location_abbr = var.location_abbr
  }
  network_resource_group = "rg-core-infra-network"
  agents_resource_group  = "rg-core-infra-agents"
  resource_group_name    = "global-rg-blackstream-infra-shared-${local.context.location_abbr}"
  key_vault_name         = "${local.context.environment}-kv-bs-${var.domain_name}-${var.location_abbr}"

  subnet_agents_name = "subnet-agents"
  tags               = {}
}

module "rg_network" {
  source              = "../../../../DevOps/terraform/modules/resource-group"
  context             = local.context
  belong_to_team      = var.team_name
  resource_group_name = local.network_resource_group
  tags                = local.tags
  prevent_destroy     = true
}

module "rg_agents" {
  source              = "../../../../DevOps/terraform/modules/resource-group"
  context             = local.context
  belong_to_team      = var.team_name
  resource_group_name = local.agents_resource_group
  tags                = local.tags
  prevent_destroy     = true
}

module "rg_global_resource" {
  source              = "../../../../DevOps/terraform/modules/resource-group"
  context             = local.context
  belong_to_team      = var.team_name
  resource_group_name = local.resource_group_name
  tags                = local.tags
  prevent_destroy     = true
}

module "domain_key_vault" {
  source                  = "../../../../DevOps/terraform/modules/key-vault"
  resource_group          = module.rg_global_resource.resource_group
  key_vault_name          = local.key_vault_name
  context                 = local.context
  environment             = var.environment
  tags                    = local.tags
  log_analytics_retention = var.log_analytics_retention
  depends_on = [
    module.rg_global_resource
  ]
}

module "log_workspace" {
  source                     = "../../../../DevOps/terraform/modules/monitoring"
  resource_group             = module.rg_global_resource.resource_group
  environment                = var.environment
  context                    = local.context
  log_analytics_retention    = var.log_analytics_retention
  internet_ingestion_enabled = var.internet_ingestion_enabled
  internet_query_enabled     = var.internet_query_enabled
  depends_on = [
    module.rg_global_resource
  ]
}

module "wan_global" {
  source                 = "../../../../devops/terraform/modules/virtual-wan"
  resource_group         = module.rg_network.resource_group
  environment            = var.environment
  wan_name               = var.wan_name
  wan_hubs               = var.wan_hubs
  hub_connections        = var.hub_connections
  firewall_private_ip    = module.virtual_hub_firewall.fw_private_ip
  hub_route_tables       = var.hub_route_tables
  default_route_table_id = var.default_route_table_id
  depends_on = [
    module.rg_network
  ]
}
module "virtual_hub_firewall_policy" {
  source             = "../../../../devops/terraform/modules/firewall-policy"
  resource_group     = module.rg_network.resource_group
  environment        = var.environment
  firewall_name      = var.firewall_name
  firewall_public_ip = module.virtual_hub_firewall.fw_public_ip
  #firewall_application_rules  = var.firewall_application_rules
  firewall_network_rules = var.firewall_network_rules
  firewall_nat_rules     = var.firewall_nat_rules
}

module "virtual_hub_firewall" {
  source                      = "../../../../devops/terraform/modules/virtual-hub-firewall"
  resource_group              = module.rg_network.resource_group
  environment                 = var.environment
  context                     = local.context
  firewall_name               = var.firewall_name
  firewall_policy_id          = module.virtual_hub_firewall_policy.policy_id
  firewall_sku_tier           = var.firewall_sku_tier
  firewall_availibility_zones = var.firewall_availibility_zones
  log_analytics_retention     = var.log_analytics_retention
  depends_on = [
    module.rg_global_resource, module.log_workspace
  ]
}

module "vnets" {
  for_each                = { for vnet in [var.core_vnet, var.utils_vnet] : vnet.name => vnet }
  source                  = "../../../../DevOps/terraform/modules/virtual-network"
  vnet                    = each.value
  context                 = local.context
  resource_group          = module.rg_network.resource_group
  environment             = var.environment
  tags                    = local.tags
  log_analytics_retention = var.log_analytics_retention
  depends_on = [
    module.rg_global_resource, module.log_workspace
  ]
}

module "vmss_agents" {
  source         = "../../../../DevOps/terraform/modules/win-vmss"
  resource_group = module.rg_agents.resource_group
  context        = local.context
  environment    = var.environment
  vnet_config    = module.vnets["prod-vnet-utils-services"].vnet_config
  subnet_name    = local.subnet_agents_name
  vmss_configs   = var.agents_vmss_configs
  tags           = local.tags
  depends_on = [
    module.rg_global_resource, module.log_workspace
  ]
}


module "vmss_agents_win" {
  source         = "../../../../DevOps/terraform/modules/win-vmss"
  resource_group = module.rg_agents.resource_group
  context        = local.context
  environment    = var.environment
  vnet_config    = module.vnets["prod-vnet-utils-services"].vnet_config
  subnet_name    = local.subnet_agents_name
  create_nsg     = false
  vmss_configs   = var.agents_vmss_configs_from_image
  tags           = local.tags
  depends_on = [
    module.rg_global_resource, module.log_workspace
  ]
}


# module "azure_policy_definitions_global" {
#   source = "../../../../devops/terraform/modules/azure-policy/global-policy-definitions"
# }

module "azure_policyset_definitions_global" {
  source                     = "../../../../devops/terraform/modules/azure-policy/global-policyset-definitions"
  global_management_group_id = var.global_management_group_id
  # eventhub_id                = module.azure_policy_definitions_global.eventhub_id
  # databricks_id              = module.azure_policy_definitions_global.databricks_id
}

module "azure_policy_assignments_global" {
  source                     = "../../../../devops/terraform/modules/azure-policy/global-policy-assignments"
  policy_initiative_name     = var.policy_initiative_name
  policy_initiative_id       = module.azure_policyset_definitions_global.global_initiative_id
  global_management_group_id = var.global_management_group_id
}

# module "azure_policyset_definitions_platform" {
#   source = "../../../../devops/terraform/modules/azure-policy/platform-policyset-definitions"
#   platform_management_group_id = var.platfrom_management_group_id
# }

# module "dns_private_resolver" {
#   source                       = "../../../../devops/terraform/modules/private-dns-resolver"
#   resource_group   = module.rg_agents.resource_group
#   environment      = var.environment
#   dnsresolver_name = var.dnsresolver_name
#   subscription_id = var.subscription_id 
#   tenant_id       = var.tenant_id 
# }

