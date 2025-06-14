data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

resource "azurerm_kubernetes_cluster" "main" {
  name                    = var.cluster_name
  kubernetes_version      = var.kubernetes_version
  location                = data.azurerm_resource_group.main.location
  resource_group_name     = data.azurerm_resource_group.main.name
  node_resource_group     = var.node_resource_group
  dns_prefix              = "aks"
  sku_tier                = var.sku_tier
  private_cluster_enabled = var.private_cluster_enabled

  linux_profile {
    admin_username = var.admin_username

    ssh_key {
      # remove any new lines using the replace interpolation function
      key_data = replace(tls_private_key.ssh.public_key_openssh, "\n", "")
    }
  }

  dynamic "default_node_pool" {
    for_each = var.enable_auto_scaling == true ? [] : ["default_node_pool_manually_scaled"]
    content {
      orchestrator_version   = var.orchestrator_version
      name                   = var.system_pool_name
      node_count             = var.system_pool_count
      vm_size                = var.system_node_vm_size
      os_disk_size_gb        = var.os_disk_size_gb
      vnet_subnet_id         = var.vnet_subnet_id
      enable_auto_scaling    = var.enable_auto_scaling
      max_count              = null
      min_count              = null
      enable_node_public_ip  = var.enable_node_public_ip
      zones                  = var.node_pool_zones
      node_labels            = var.system_pool_labels
      type                   = var.agents_type
      tags                   = merge(var.tags, var.system_node_pool_tags)
      max_pods               = var.system_node_max_pods
      enable_host_encryption = var.enable_host_encryption
    }
  }

  dynamic "default_node_pool" {
    for_each = var.enable_auto_scaling == true ? ["default_node_pool_auto_scaled"] : []
    content {
      orchestrator_version   = var.orchestrator_version
      name                   = var.system_pool_name
      vm_size                = var.system_node_vm_size
      os_disk_size_gb        = var.os_disk_size_gb
      vnet_subnet_id         = var.vnet_subnet_id
      enable_auto_scaling    = var.enable_auto_scaling
      max_count              = var.system_pool_max_count
      min_count              = var.system_pool_min_count
      enable_node_public_ip  = var.enable_node_public_ip
      zones                  = var.node_pool_zones
      node_labels            = var.system_pool_labels
      type                   = var.agents_type
      tags                   = merge(var.tags, var.system_node_pool_tags)
      max_pods               = var.system_node_max_pods
      enable_host_encryption = var.enable_host_encryption
    }
  }

  dynamic "service_principal" {
    for_each = var.client_id != "" && var.client_secret != "" ? ["service_principal"] : []
    content {
      client_id     = var.client_id
      client_secret = var.client_secret
    }
  }

  http_application_routing_enabled = var.enable_http_application_routing

  azure_policy_enabled = var.enable_azure_policy

  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  dynamic "ingress_application_gateway" {
    for_each = var.enable_ingress_application_gateway == null ? [] : ["ingress_application_gateway"]
    content {
      gateway_id   = var.ingress_application_gateway_id
      gateway_name = var.ingress_application_gateway_name
      subnet_cidr  = var.ingress_application_gateway_subnet_cidr
      subnet_id    = var.ingress_application_gateway_subnet_id
    }
  }

  role_based_access_control_enabled = var.enable_role_based_access_control

  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.enable_role_based_access_control && var.rbac_aad_managed ? ["rbac"] : []
    content {
      managed                = true
      admin_group_object_ids = var.rbac_aad_admin_group_object_ids
    }
  }

  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.enable_role_based_access_control && !var.rbac_aad_managed ? ["rbac"] : []
    content {
      managed           = false
      client_app_id     = var.rbac_aad_client_app_id
      server_app_id     = var.rbac_aad_server_app_id
      server_app_secret = var.rbac_aad_server_app_secret
    }
  }

  network_profile {
    network_plugin     = var.network_plugin
    network_policy     = var.network_policy
    dns_service_ip     = var.net_profile_dns_service_ip
    docker_bridge_cidr = var.net_profile_docker_bridge_cidr
    outbound_type      = var.net_profile_outbound_type
    pod_cidr           = var.net_profile_pod_cidr
    service_cidr       = var.net_profile_service_cidr
  }
  private_dns_zone_id = var.private_dns_zone_id

  tags = var.tags
  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "workload_pool" {
  name                  = var.workload_pool_name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = var.workload_node_vm_size
  enable_auto_scaling   = true
  orchestrator_version  = var.orchestrator_version
  os_disk_size_gb       = var.os_disk_size_gb
  vnet_subnet_id        = var.vnet_subnet_id
  max_count             = var.workload_pool_node_max_count
  min_count             = var.workload_pool_node_min_count
  enable_node_public_ip = var.enable_node_public_ip
  zones                 = var.node_pool_zones
  node_labels           = var.workload_pool_labels
  tags                  = merge(var.tags, var.system_node_pool_tags)
  max_pods              = var.workload_node_max_pods
  lifecycle {
    prevent_destroy = true
  }
}


