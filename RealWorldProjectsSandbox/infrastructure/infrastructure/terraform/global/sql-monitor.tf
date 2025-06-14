locals {


  key_vault = {
    resource_group_name = data.azurerm_key_vault.infra_key_vault.resource_group_name
    key_vault_name      = data.azurerm_key_vault.infra_key_vault.name
  }

  sql_monitor_resource_group_name = "${var.environment}-rg-${var.product}-sql-monitor-${var.location_abbr}"
  nsg_name                        = "${var.environment}-nsg-${var.product}-sql-monitor-vm"
}

###########################################################
#         DATA Sources
###########################################################
data "azurerm_key_vault" "infra_key_vault" {
  name                = local.key_vault_name
  resource_group_name = local.resource_group_name
  depends_on = [
    module.domain_key_vault
  ]
}

# existing subnet 
data "azurerm_subnet" "sql_monitor" {
  name                 = var.shared_vm_config.subnet_name
  virtual_network_name = var.shared_vm_config.virtual_network_name
  resource_group_name  = var.shared_vm_config.vnet_rg
  depends_on = [
    module.vnets
  ]
}
# existing Application Insight
data "azurerm_log_analytics_workspace" "workspace" {
  name                = var.shared_vm_config.log_analytics_name
  resource_group_name = var.shared_vm_config.log_analytics_rg
}

###########################################################
#         Sources
###########################################################

module "rg_vm" {
  source              = "../../../../DevOps/terraform/modules/resource-group"
  context             = local.context
  belong_to_team      = var.team_name
  resource_group_name = local.sql_monitor_resource_group_name
  tags                = local.tags
  prevent_destroy     = false
}

module "nsg_vm" {
  source              = "../../../../DevOps/terraform/modules/network-security-group"
  resource_group      = module.rg_vm.resource_group
  context             = local.context
  domain              = var.domain_name
  security_group_name = local.nsg_name


  # Custom inbound and outbound rules
  custom_rules = [
    {
      name                       = "rdp"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3389"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "RDP Connection"
    },
    {
      name                       = "https"
      priority                   = 120
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Secure SSL"
    }
  ]
}



module "redgate_vm" {
  for_each                           = var.vm_configs
  source                             = "../../../../DevOps/terraform/modules/virtual-machine"
  context                            = local.context
  environment                        = var.environment
  product                            = var.product
  customized_key_vault_name          = var.shared_vm_config.customized_key_vault_name
  resource_group                     = module.rg_vm.resource_group
  subnet_id                          = data.azurerm_subnet.sql_monitor.id
  virtual_machine_name               = each.key
  windows_distribution_name          = var.shared_vm_config.windows_distribution_name
  virtual_machine_size               = var.shared_vm_config.virtual_machine_size
  instances_count                    = 1
  admin_username                     = var.shared_vm_config.admin_username
  need_local_user                    = true
  add_to_aad                         = true
  os_disk_storage_account_type       = var.shared_vm_config.os_disk_storage_account_type
  storage_os_disk_caching            = var.shared_vm_config.storage_os_disk_caching
  extra_disks                        = var.extra_disks
  delete_os_disk_on_termination      = var.shared_vm_config.delete_os_disk_on_termination
  nb_data_disk                       = var.shared_vm_config.nb_data_disk
  data_sa_type                       = var.shared_vm_config.data_sa_type
  data_disk_size_gb                  = var.shared_vm_config.data_disk_size_gb
  network_security_group_id          = module.nsg_vm.id
  private_ip_address_allocation_type = each.value.ip_address_type
  private_ip_address                 = each.value.static_ip_addresses
  tags                               = local.tags
  workspace_id                       = data.azurerm_log_analytics_workspace.workspace.workspace_id
  workspace_primary_shared_key       = data.azurerm_log_analytics_workspace.workspace.primary_shared_key
  depends_on = [
    module.domain_key_vault
  ]
}



resource "azurerm_subnet_network_security_group_association" "nsgassoc" {
  subnet_id                 = data.azurerm_subnet.sql_monitor.id
  network_security_group_id = module.nsg_vm.id
}
