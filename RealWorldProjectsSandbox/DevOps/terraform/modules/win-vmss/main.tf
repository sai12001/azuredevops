locals {
  tags = merge(var.resource_group.tags, var.tags)
  vmss_configs = defaults(var.vmss_configs, {
    sku            = "Standard_F2s_v2"
    instances      = 1
    admin_username = "vmadmin"
    image = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2019-Datacenter"
      version   = "latest"
    }
    os_disk = {
      storage_account_type = "Standard_LRS"
      caching              = "ReadWrite"
    }
  })
  # Diagnostic Settings Config
  log_workspace = {
    name                = "${var.context.environment}-logs-${var.context.product}-workspace-${var.context.location_abbr}"
    resource_group_name = "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
  }
}
data "azurerm_virtual_network" "vnet" {
  name                = var.vnet_config.name
  resource_group_name = var.vnet_config.resource_group
}

data "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = var.vnet_config.resource_group
  virtual_network_name = data.azurerm_virtual_network.vnet.name
}

data "azurerm_log_analytics_workspace" "law" {
  name                = local.log_workspace.name
  resource_group_name = local.log_workspace.resource_group_name
}

resource "random_password" "vm_password" {
  length  = 24
  special = false
  upper   = true
  lower   = true
}

resource "random_string" "nsg_suffix" {
  length  = 8
  special = false
  upper   = false
  lower   = true
}

resource "random_string" "nic_suffix" {
  length  = 8
  special = false
  upper   = false
  lower   = true
}

# Create Network Security Group For Agents Subnet
resource "azurerm_network_security_group" "subnet_nsg" {
  count               = var.create_nsg ? 1 : 0
  name                = "prd-nsg-vmss-nsg-${random_string.nsg_suffix.result}"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  security_rule {
    name                       = "AllowRDP"
    description                = "Allow RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }
}

# Associate the NSG with the Subnet
resource "azurerm_subnet_network_security_group_association" "subnet_nsg_association" {
  count                     = var.create_nsg ? 1 : 0
  subnet_id                 = data.azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.subnet_nsg[0].id
  lifecycle {
    ignore_changes = [subnet_id]
  }
}

resource "azurerm_windows_virtual_machine_scale_set" "vmss" {
  name                   = local.vmss_configs.name
  resource_group_name    = var.resource_group.name
  location               = var.resource_group.location
  sku                    = local.vmss_configs.sku
  instances              = local.vmss_configs.instances
  admin_password         = random_password.vm_password.result
  admin_username         = local.vmss_configs.admin_username
  computer_name_prefix   = local.vmss_configs.computer_name_prefix
  overprovision          = false
  single_placement_group = false
  source_image_id        = local.vmss_configs.image_id

  dynamic "source_image_reference" {
    for_each = local.vmss_configs.image_id == null ? [1] : []

    content {
      publisher = local.vmss_configs.image.publisher
      offer     = local.vmss_configs.image.offer
      sku       = local.vmss_configs.image.sku
      version   = local.vmss_configs.image.version

    }
  }

  os_disk {
    storage_account_type = local.vmss_configs.os_disk.storage_account_type
    caching              = local.vmss_configs.os_disk.caching
  }

  network_interface {
    name    = "prd-nic-vmss-${random_string.nic_suffix.result}"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = data.azurerm_subnet.subnet.id
    }
  }
  tags = local.tags
}

#----------------------------------------------------------------------------------------------------------
# VMSS Diagnostic Setting
#----------------------------------------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "vmss_diags" {
  name                       = format("%s-diags", azurerm_windows_virtual_machine_scale_set.vmss.name)
  target_resource_id         = azurerm_windows_virtual_machine_scale_set.vmss.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.law.id
  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }
  }
  depends_on = [
    azurerm_windows_virtual_machine_scale_set.vmss
  ]
}

# https://stackoverflow.com/questions/60265902/terraform-azurerm-virtual-machine-extension-run-local-powershell-script-using-c/60276573#60276573
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_scale_set_extension
####################
# Seems not provision entire thing, need to come back to fix it
# For now, manually provision services once up
####################
# resource "azurerm_virtual_machine_scale_set_extension" "custom_scripts" {
#   name                         = "custom-scripts-vmss"
#   virtual_machine_scale_set_id = azurerm_windows_virtual_machine_scale_set.vmss.id
#   publisher                    = "Microsoft.Compute"
#   type                         = "CustomScriptExtension"
#   type_handler_version         = "1.9"
#   protected_settings           = <<SETTINGS
#   {
#      "commandToExecute": "powershell -encodedCommand ${textencodebase64(file("install.ps1"), "UTF-16LE")}"
#   }
#   SETTINGS
#   depends_on = [
#     azurerm_windows_virtual_machine_scale_set.vmss
#   ]
# }
