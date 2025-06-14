locals {
  tags = {
    provisioner = "terraform"
    domain      = var.domain_name
    environment = var.environment
    location    = var.location_abbr
    product     = var.product
    team        = var.team_name
  }

  context = {
    product       = var.product
    environment   = var.environment
    location      = var.location
    domain        = var.domain_name
    location_abbr = var.location_abbr
  }

  # only alpha numberic supported
  resource_group_name = "${var.environment}-rg-${var.product}-${var.domain_name}-shared-${var.location_abbr}"
  key_vault_name      = "${var.environment}-kv-${var.product}-${var.domain_name}-${var.location_abbr}"
  log_workspace_name  = "${var.environment}-logs-${var.product}-workspace-${var.location_abbr}"
  vnet_config         = module.vnet_shared.vnet_config

  # used by DEV only for some legacy reason
  dev_vnet_rg = {
    name          = "dev-rg-ng-shared-infra-eau"
    tags          = local.tags
    location      = "Australia East"
    location_abbr = "eau"
  }
}

# infra resource group for shared resources
module "rg_infra" {
  source              = "../../../../../DevOps/terraform/modules/resource-group"
  context             = local.context
  belong_to_team      = var.team_name
  resource_group_name = local.resource_group_name
  tags                = local.tags
  prevent_destroy     = false
}


# vitural networks, common subnets which managed by infra, domain subnet is managed by domain
module "vnet_shared" {
  source                  = "../../../../../DevOps/terraform/modules/virtual-network"
  vnet                    = var.vnet
  resource_group          = var.environment == "dev" ? local.dev_vnet_rg : module.rg_infra.resource_group
  context                 = local.context
  environment             = var.environment
  tags                    = local.tags
  log_analytics_retention = var.log_analytics_retention
  depends_on = [
    module.rg_infra
  ]
}

# infra domain key vault 
module "domain_key_vault" {
  source                  = "../../../../../DevOps/terraform/modules/key-vault"
  resource_group          = module.rg_infra.resource_group
  key_vault_name          = local.key_vault_name
  context                 = local.context
  environment             = var.environment
  tags                    = local.tags
  log_analytics_retention = var.log_analytics_retention
  depends_on = [
    module.rg_infra
  ]
}

# private dns zones
module "private_dns" {
  source                  = "../../../../../Devops/terraform/modules/private-dns-zone"
  context                 = local.context
  resource_group          = module.rg_infra.resource_group
  provision_internal_zone = true
  provision_psql_zone     = true
  privatelink_dns_zones   = var.privatelink_dns_zones
  vnet_config             = local.vnet_config
  depends_on = [
    module.rg_infra, module.vnet_shared
  ]
}
