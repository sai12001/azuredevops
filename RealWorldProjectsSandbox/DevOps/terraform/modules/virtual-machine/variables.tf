variable "context" {
  description = "The environment context for this operation"
  type = object({
    product       = string
    environment   = string
    domain        = string
    location      = string
    location_abbr = string
  })
}

variable "product" {
  description = "The target environment resource need to deploy to, dev,stg, pef, prd etc"
  type        = string
}


variable "environment" {
  description = "The target environment resource need to deploy to, dev,stg, pef, prd etc"
  type        = string
}


variable "resource_group" {
  description = "Resoruce group object where this resource will deploy to, it suppose pass from resource group output"
  type = object({
    name          = string
    tags          = map(string)
    location      = string
    location_abbr = string
  })
}

variable "subnet_id" {
  type        = string
  description = "The name of the subnet to use in VM"
}

variable "network_security_group_id" {
  type = string
}

variable "boot_diagnostics_enabled" {
  type        = bool
  description = "Enable boot diagnostics? If so, need storage account variables"
  default     = false
}


variable "virtual_machine_name" {
  description = "The name of the virtual machine."
  type        = string
}

variable "virtual_machine_size" {
  description = "The Virtual Machine SKU for the Virtual Machine, Default is Standard_A2_V2"
  type        = string
}

variable "instances_count" {
  description = "The number of Virtual Machines required."
  type        = number
}

variable "enable_ip_forwarding" {
  description = "Should IP Forwarding be enabled? Defaults to false"
  type        = bool
  default     = false
}

variable "enable_accelerated_networking" {
  description = "Should Accelerated Networking be enabled? Defaults to false."
  type        = bool
  default     = false
}

variable "private_ip_address_allocation_type" {
  description = "The allocation method used for the Private IP Address. Possible values are Dynamic and Static."
  type        = string
  default     = "Dynamic"
}

variable "private_ip_address" {
  description = "The Static IP Address which should be used. This is valid only when `private_ip_address_allocation` is set to `Static` "
  type        = list(string)
  default     = null
}

variable "source_image_id" {
  description = "The ID of an Image which each Virtual Machine should be based on"
  type        = string
  default     = null
}

variable "custom_image" {
  description = "Provide the custom image to this module if the default variants are not sufficient"
  type = map(object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  }))
  default = null
}

variable "windows_distribution_list" {
  description = "Pre-defined Azure Windows VM images list"
  type = map(object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  }))

  default = {
    windows2019dc = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2019-Datacenter"
      version   = "latest"
    },

    mssql2019std = {
      publisher = "MicrosoftSQLServer"
      offer     = "sql2019-ws2019"
      sku       = "standard"
      version   = "latest"
    },

    mssql2019dev = {
      publisher = "MicrosoftSQLServer"
      offer     = "sql2019-ws2019"
      sku       = "sqldev"
      version   = "latest"
    },

  }
}

variable "windows_distribution_name" {
  default     = "windows2019dc"
  description = "Variable to pick an OS flavour for Windows based VM. Possible values include: winserver, wincore, winsql"
}

variable "os_disk_storage_account_type" {
  description = "The Type of Storage Account which should back this the Internal OS Disk. Possible values include Standard_LRS, StandardSSD_LRS and Premium_LRS."
  default     = "StandardSSD_LRS"
}

variable "storage_os_disk_caching" {
  type        = string
  description = "Specifies the caching requirements for the os Disk. Possible values include None, ReadOnly and ReadWrite"
  default     = "ReadWrite"
}

variable "extra_disks" {
  description = "(Optional) List of extra data disks attached to each virtual machine."
  type = list(object({
    name = string
    size = number
  }))
  default = [{
    name = "disk2"
    size = 10
  }]
}


variable "delete_os_disk_on_termination" {
  type        = bool
  description = "Delete datadisk when machine is terminated."
  default     = true
}

variable "nb_data_disk" {
  description = "(Optional) Number of the data disks attached to each virtual machine."
  type        = number
  default     = 0
}

variable "data_sa_type" {
  description = "Data Disk Storage Account type."
  type        = string
  default     = "Standard_LRS"
}

variable "data_disk_size_gb" {
  description = "Storage data disk size size."
  type        = number
  default     = 50
}


variable "disable_password_authentication" {
  description = "Should Password Authentication be disabled on this Virtual Machine? Defaults to true."
  type        = string
  default     = false
}

variable "admin_username" {
  description = "The username of the local administrator used for the Virtual Machine."
  type        = string
}

variable "admin_password" {
  description = "The Password which should be used for the local-administrator on this Virtual Machine"
  type        = string
  default     = null
}

variable "add_to_aad" {
  type        = bool
  description = "Is the VM need to add to AAD."
  default     = false
}

variable "need_local_user" {
  type        = bool
  description = "Is the VM need local user to be created."
  default     = false
}

variable "license_type" {
  description = "Specifies the type of on-premise license which should be used for this Virtual Machine. Possible values are Windows_Client and Windows_Server."
  type        = string
  default     = null
}

# Variables used on VM extension 
variable "oms_publisher" {
  description = "The oms VM extension publisher"
  type        = string
  default     = "Microsoft.EnterpriseCloud.Monitoring"
}

variable "oms_type" {
  description = "The oms VM extension type"
  type        = string
  default     = "MicrosoftMonitoringAgent"
}

variable "oms_version" {
  description = "The oms VM extension version"
  type        = string
  default     = "1.0"
}

variable "workspace_id" {
  type        = string
  description = "The log analytics workspace id to sink logs"
}

variable "workspace_primary_shared_key" {
  description = "primary/shared key from a Log Analytics Workspace"
  type        = string
}

variable "tags" {
  description = "Tags need to attach to this resource"
  type        = map(string)
  default     = {}
}

variable "customized_key_vault_name" {
  description = "if virtual machine passwords wants store in different keyvault. "
  type        = string
  default     = null
}
