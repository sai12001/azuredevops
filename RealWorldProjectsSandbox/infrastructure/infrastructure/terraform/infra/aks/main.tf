locals {
  net_profile_dns_service_ip     = "170.20.0.10"
  net_profile_docker_bridge_cidr = "170.10.0.1/16"
  net_profile_service_cidr       = "170.20.0.0/16"
  net_profile_pod_cidr           = "170.244.0.0/16"
  region_zones                   = ["1", "2"]
  agent_types                    = "VirtualMachineScaleSets"
  admin_group_id                 = "d5b38d6b-b008-4881-a147-65c44f32e833" # Global - DevOps
  cluster_name                   = "${var.environment}-aks-${var.product}-main-${var.location_abbr}"
  max_pods                       = 100
  tags = {
    environment = var.environment
    provisioner = "terraform"
  }
}
resource "azurerm_resource_group" "rg_aks" {
  name     = "${var.environment}-rg-${var.product}-aks-${var.location_abbr}"
  location = var.location
  tags     = local.tags
}

data "azurerm_virtual_network" "vnet_shared" {
  name                = var.vnet_name
  resource_group_name = var.vnet_rg
}

# this will be provision by tf too in the future
data "azurerm_subnet" "subnet_aks" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.vnet_rg
}

data "azurerm_key_vault" "kv_tf_bootstrap" {
  name                = "${var.environment}-kv-${var.product}-tf-creds-${var.location_abbr}"
  resource_group_name = "${var.environment}-rg-${var.product}-tf-bootstrap-${var.location_abbr}"
}

data "azurerm_key_vault_secret" "kv_aks_spn_secrets" {
  for_each     = toset(["spn-aks-cluster-id", "spn-aks-cluster-secret"])
  name         = each.key
  key_vault_id = data.azurerm_key_vault.kv_tf_bootstrap.id
}


resource "azurerm_private_dns_zone" "aks_private_dns_zone" {
  name                = var.private_dns_zone
  resource_group_name = azurerm_resource_group.rg_aks.name
  tags                = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "spoke_vnet_link" {
  name                  = "zone_vnet_link_aks_internal_${var.environment}"
  resource_group_name   = azurerm_resource_group.rg_aks.name
  private_dns_zone_name = azurerm_private_dns_zone.aks_private_dns_zone.name
  virtual_network_id    = data.azurerm_virtual_network.vnet_shared.id
  tags                  = local.tags

  depends_on = [
    azurerm_private_dns_zone.aks_private_dns_zone
  ]
}

module "aks" {
  source                           = "../../DevOps/modules/aks"
  resource_group_name              = azurerm_resource_group.rg_aks.name
  client_id                        = data.azurerm_key_vault_secret.kv_aks_spn_secrets["spn-aks-cluster-id"].value
  client_secret                    = data.azurerm_key_vault_secret.kv_aks_spn_secrets["spn-aks-cluster-secret"].value
  kubernetes_version               = var.aks_version
  orchestrator_version             = var.aks_version
  cluster_name                     = local.cluster_name
  network_plugin                   = "kubenet"
  vnet_subnet_id                   = data.azurerm_subnet.subnet_aks.id
  enable_role_based_access_control = true
  rbac_aad_admin_group_object_ids  = [local.admin_group_id]
  rbac_aad_managed                 = true
  private_cluster_enabled          = false # default value TODO: once VPN is up and running, we need to make this fully private
  enable_http_application_routing  = false
  enable_azure_policy              = true
  enable_auto_scaling              = true
  enable_host_encryption           = false
  system_pool_min_count            = var.system_node_pool_min_no
  system_pool_max_count            = var.system_node_pool_max_no
  system_pool_count                = null # Please set `system_pool_count` `null` while `enable_auto_scaling` is `true` to avoid possible `system_pool_count` changes.
  system_node_max_pods             = local.max_pods
  system_pool_name                 = var.system_node_pool_name
  node_pool_zones                  = local.region_zones
  agents_type                      = local.agent_types
  sku_tier                         = var.aks_sku_tier
  log_analytics_workspace_id       = var.log_workspace_id
  system_node_vm_size              = var.system_node_pool_node_size
  workload_pool_node_min_count     = var.workload_node_pool_min_no
  workload_pool_node_max_count     = var.workload_node_pool_max_no
  workload_pool_name               = var.workload_node_pool_name
  workload_node_vm_size            = var.workload_node_pool_node_size
  tags                             = local.tags

  system_pool_labels = {
    "nodepool" : "system"
  }
  system_node_pool_tags = {
    "Agent" : "system"
  }
  workload_pool_labels = {
    "nodepool" : "workload"
  }

  network_policy                 = null
  net_profile_dns_service_ip     = local.net_profile_dns_service_ip
  net_profile_docker_bridge_cidr = local.net_profile_docker_bridge_cidr
  net_profile_service_cidr       = local.net_profile_service_cidr
  net_profile_pod_cidr           = local.net_profile_pod_cidr

  depends_on = [azurerm_resource_group.rg_aks]
}

resource "azurerm_key_vault_secret" "secret_ssh_private_key" {
  name         = "aks-node-ssh-private-key"
  key_vault_id = data.azurerm_key_vault.kv_tf_bootstrap.id
  value        = module.aks.private_ssh_key
}

resource "azurerm_key_vault_secret" "secret_ssh_public_key" {
  name         = "aks-node-ssh-public-key"
  key_vault_id = data.azurerm_key_vault.kv_tf_bootstrap.id
  value        = module.aks.public_ssh_key
}
