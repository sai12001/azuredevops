variable "context" {
  description = "The environment context for this operation"
  type = object({
    product       = string
    environment   = string
    location      = string
    location_abbr = string
  })
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

variable "vnet_config" {
  description = "vnet configuration for this vmss"
  type = object({
    name           = string
    resource_group = string
  })
}

variable "subnet_name" {
  description = "the subnet name for vmss"
  type        = string
  default     = "subnet-agents"
}

variable "create_nsg" {
  type = bool
  default = true
}


variable "vmss_configs" {
  description = "VMSS configuration"
  type = object({
    name                 = string
    computer_name_prefix = string
    sku                  = optional(string)
    instances            = optional(number)
    admin_username       = optional(string)
    image = optional(object({
      publisher = optional(string)
      offer     = optional(string)
      sku       = optional(string)
      version   = optional(string)
    }))
    image_id = optional(string)
    os_disk = optional(object({
      storage_account_type = optional(string)
      caching              = optional(string)
    }))
  })

}


variable "tags" {
  description = "Tags need to attach to this resource"
  type        = map(string)
  default     = {}
}
