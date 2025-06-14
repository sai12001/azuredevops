
#----------------------------------------------------------
# Storage & Random Resources
#----------------------------------------------------------
resource "azurerm_storage_account" "diag_storage" {
  count                    = var.boot_diagnostics_enabled != false ? var.instances_count : 0
  name                     = lower(replace("stavm${var.virtual_machine_name}${count.index}", "-", ""))
  location                 = var.resource_group.location
  resource_group_name      = var.resource_group.name
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags                     = var.resource_group.tags
}


resource "random_password" "passwd" {
  length      = 24
  min_upper   = 4
  min_lower   = 2
  min_numeric = 4
  special     = false
  keepers = {
    admin_password = var.admin_password
  }
}

resource "random_password" "local_user_passwd" {
  count       = var.need_local_user == true ? var.instances_count : 0
  length      = 24
  min_upper   = 4
  min_lower   = 2
  min_numeric = 4
  special     = false
  keepers = {
    admin_password = var.admin_password
  }
}
#---------------------------------------
# Network Interface for Virtual Machine
#---------------------------------------
resource "azurerm_network_interface" "nic" {
  count                         = var.instances_count
  name                          = "${var.environment}-vm-${var.product}-${var.virtual_machine_name}-nic-${count.index}"
  location                      = var.resource_group.location
  resource_group_name           = var.resource_group.name
 # enable_ip_forwarding          = var.enable_ip_forwarding
 # enable_accelerated_networking = var.enable_accelerated_networking
  tags                          = var.resource_group.tags
  ip_configuration {
    name                          = lower("ipconfig-${var.environment}-vm-${var.product}-${var.virtual_machine_name}-${count.index}")
    primary                       = true
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = var.private_ip_address_allocation_type
    private_ip_address            = var.private_ip_address_allocation_type == "Static" ? var.private_ip_address[count.index] : null
  }
}

#---------------------------------------
# Windows Virutal machine
#---------------------------------------
resource "azurerm_virtual_machine" "win_vm" {
  count                            = var.instances_count
  name                             = "${var.environment}-vm-${var.product}-${var.virtual_machine_name}-${count.index}"
  location                         = var.resource_group.location
  resource_group_name              = var.resource_group.name
  vm_size                          = var.virtual_machine_size
  network_interface_ids            = [element(concat(azurerm_network_interface.nic.*.id, [""]), count.index)]
  delete_os_disk_on_termination    = var.delete_os_disk_on_termination
  delete_data_disks_on_termination = true
  license_type                     = var.license_type
  tags                             = var.resource_group.tags
  os_profile {
    #computer_name = var.virtual_machine_name[count.index]
    computer_name = "${var.virtual_machine_name}${count.index}"

    # data.azurerm_key_vault_secret.admin_username.value
    admin_username = var.admin_username

    # data.azurerm_key_vault_secret.password.value
    admin_password = var.admin_password == null ? element(concat(random_password.passwd.*.result, [""]), 0) : var.admin_password
  }
  dynamic "storage_image_reference" {
    for_each = var.source_image_id != null ? [] : [1]
    content {
      publisher = var.custom_image != null ? var.custom_image["publisher"] : var.windows_distribution_list[lower(var.windows_distribution_name)]["publisher"]
      offer     = var.custom_image != null ? var.custom_image["offer"] : var.windows_distribution_list[lower(var.windows_distribution_name)]["offer"]
      sku       = var.custom_image != null ? var.custom_image["sku"] : var.windows_distribution_list[lower(var.windows_distribution_name)]["sku"]
      version   = var.custom_image != null ? var.custom_image["version"] : var.windows_distribution_list[lower(var.windows_distribution_name)]["version"]
    }
  }
  os_profile_windows_config {
    provision_vm_agent = true
  }
  boot_diagnostics {
    enabled     = var.boot_diagnostics_enabled
    storage_uri = var.boot_diagnostics_enabled != false ? azurerm_storage_account.diag_storage[count.index].primary_blob_endpoint : ""
  }
  storage_os_disk {
    # name              = "osdisk-${var.virtual_machine_name[count.index]}"
    name              = "${var.environment}-vm-${var.product}-${var.virtual_machine_name}-${count.index}-os"
    create_option     = "FromImage"
    caching           = var.storage_os_disk_caching
    managed_disk_type = var.os_disk_storage_account_type
  }
  dynamic "storage_data_disk" {
    for_each = range(var.nb_data_disk)
    content {
      #name              = "${var.virtual_machine_name[count.index]}-datadisk-${storage_data_disk.value}"
      name              = "${var.environment}-vm-${var.product}-${var.virtual_machine_name}-${count.index}-data-01"
      create_option     = "Empty"
      lun               = storage_data_disk.value
      disk_size_gb      = var.data_disk_size_gb
      managed_disk_type = var.data_sa_type
    }
  }
  /*
  dynamic "storage_data_disk" {
    for_each = var.extra_disks
    content {
      name              = "${var.environment}-vm-${var.product}-${var.virtual_machine_name[count.index]}-data-02"
      create_option     = "Empty"
      lun               = storage_data_disk.key + var.nb_data_disk
      disk_size_gb      = storage_data_disk.value.size
      managed_disk_type = var.data_sa_type
    }
    
  }
  */
}

#---------------------------------------
# Azure Virtual Machine Extension used to connect the VM with Log Analytics
#---------------------------------------
resource "azurerm_virtual_machine_extension" "win-oms" {
  count                      = var.instances_count
  name                       = "${var.environment}-vm-${var.product}-${var.virtual_machine_name}-${count.index}-OMSExtension"
  virtual_machine_id         = azurerm_virtual_machine.win_vm[count.index].id
  publisher                  = var.oms_publisher
  type                       = var.oms_type
  type_handler_version       = var.oms_version
  auto_upgrade_minor_version = true
  settings                   = <<SETTINGS
    {
      "workspaceId" : "${var.workspace_id}"
    }
  SETTINGS
  protected_settings         = <<PROTECTED_SETTINGS
    {
      "workspaceKey" : "${var.workspace_primary_shared_key}"
    }
  PROTECTED_SETTINGS
}

resource "azurerm_virtual_machine_extension" "join_aad" {
  count                = var.add_to_aad == true ? var.instances_count : 0
  name                 = "AADLogin"
  virtual_machine_id   = azurerm_virtual_machine.win_vm[count.index].id
  publisher            = "Microsoft.Azure.ActiveDirectory"
  type                 = "AADLoginForWindows"
  type_handler_version = "1.0"
}


resource "null_resource" "run_command" {
  count = var.add_to_aad == true ? var.instances_count : 0
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = <<EOT
      .'${path.module}/customscripts/Run_Command.ps1' `
      -resourceGroupName '${var.resource_group.name}' `
      -vmName '${azurerm_virtual_machine.win_vm[count.index].name}' `
      -scriptPath '${path.module}/customscripts' `
      -local_user_pwd '${random_password.local_user_passwd[0].result}' `
      -need_local_user '${var.need_local_user}'
      EOT

    interpreter = ["PowerShell", "-Command"]
  }

  depends_on = [
    azurerm_virtual_machine.win_vm,
    azurerm_key_vault_secret.local_username,
    random_password.local_user_passwd
  ]
}


#---------------------------------------
# Azure Key Vault data source and admin password creation
#---
data "azurerm_key_vault" "key_vault" {
  name                = var.customized_key_vault_name == null ? "${var.context.environment}-kv-${var.product}-${var.context.domain}-${var.context.location_abbr}" : var.customized_key_vault_name
  resource_group_name = "${var.context.environment}-rg-${var.product}-${var.context.domain}-shared-${var.context.location_abbr}"
}

resource "azurerm_key_vault_secret" "admin_username" {
  count        = var.instances_count
  key_vault_id = data.azurerm_key_vault.key_vault.id
  # name         = "windows-administrator-password-${var.virtual_machine_name}"
  name  = lower("${var.environment}-vm-${var.product}-${var.virtual_machine_name}-localadmin")
  value = var.admin_password == null ? random_password.passwd.result : var.admin_password
  lifecycle {
    ignore_changes = [
      key_vault_id
    ]
  }
}

#---------------------------------------
# Azure Key Vault data source and local user password creation
#---
resource "azurerm_key_vault_secret" "local_username" {
  count        = var.need_local_user == true ? var.instances_count : 0
  key_vault_id = data.azurerm_key_vault.key_vault.id
  # name         = "windows-administrator-password-${var.virtual_machine_name}"
  name  = lower("${var.environment}-vm-${var.product}-${var.virtual_machine_name}-localuser")
  value = random_password.local_user_passwd[0].result
  lifecycle {
    ignore_changes = [
      key_vault_id
    ]
  }
}

#---------------------------------------
# AutoManage Profile Assignment
#---------------------------------------
# data "azurerm_resource_group" "rg"{
#   name = "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
# }

# data "azapi_resource" "automanage_profile" {
#   name      = "${var.context.environment}-automanage-${var.context.product}-infra-shared-${var.context.location_abbr}"
#   parent_id = data.azurerm_resource_group.rg.id
#   type      = "Microsoft.Automanage/configurationProfiles@2022-05-04"
#   response_export_values = ["properties.id"]
# }
# output "profile_id" {
#   value = jsondecode(data.azapi_resource.automanage_profile.output).properties.id
# }
# resource "azapi_resource" "automanage_profile_assignment" {
#   type = "Microsoft.Compute/virtualMachines/providers/configurationProfileAssignments"
#   parent_id = data.azurerm_resource_group.rg.id
#   location = "australiaeast"
#   name = "{azurerm_virtual_machine.win_vm.name}/Microsoft.Automanage/default"
#   body = jsonencode({
#     properties = {
#       configurationProfile = "azapi_resource.automanage_profile.profile_id"
#     }
#   })
# }
