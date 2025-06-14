variable "resource_group" {
  description = "Resoruce group object where this resource will deploy to, it suppose pass from resource group output"
  type = object({
    name          = string
    tags          = map(string)
    location      = string
    location_abbr = string
  })
}

variable "instance_name" {
  description = "required name of the sql mi instance"
  type        = string
}

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

variable "key_vault" {
  description = "The shared key vault"
  type = object({
    resource_group_name = string
    key_vault_name      = string
  })
}

variable "vnet_config" {
  description = "The shared vnet configuration"
  type = object({
    name           = string
    resource_group = string
  })
}

variable "tags" {
  description = "Tags need to attach to this resource group"
  type        = map(string)
  default     = {}
}

variable "administrator_login" {
  description = "administrator login name"
  type        = string
  default     = "tbs-sa"
}

variable "db_user" {
  description = "A user for the apps to use"
  type        = string
}

variable "collation" {
  description = "Specifies how the SQL Managed Instance will be collated"
  type        = string
  default     = "Latin1_General_CI_AS"
}

variable "proxy_override" {
  description = "proxy override of the sql managed instance"
  type        = string
  default     = "Default"
}

variable "timezone_id" {
  description = "The TimeZone ID that the SQL Managed Instance will be operating in"
  type        = string
  default     = "AUS Eastern Standard Time"
}

variable "license_type" {
  description = "license type of the sql managed instance"
  type        = string
  default     = "BasePrice"
}
variable "sku_name" {
  description = "skuname of the sql managed instance"
  type        = string
  default     = "GP_Gen5"
}

variable "vcores" {
  description = "no of cores of the sql managed instance"
  type        = number
  default     = 4
}

variable "storage_account_type" {
  description = "stroage account type of the sql managed instance"
  type        = string
  default     = "GRS"
}

variable "storage_size_in_gb" {
  description = "storage in size of the sql managed instance"
  type        = number
  default     = 1024
}

variable "public_data_endpoint_enabled" {
  description = "is allowed public access"
  type        = bool
}
variable "subnet_name" {
  description = "subnet name of the SQL managedf instance"
  type        = string
}

variable "databases" {
  description = "list of databases"
  type = list(object({
    name = string
  }))
  default = []
}

variable "network_security_group_rules" {
  description = "list of network security group rules"
  type = list(object({
    name                       = string                 //"allow_management_inbound"
    priority                   = string                 //101
    direction                  = string                 //"Inbound"
    access                     = string                 //"Allow"
    protocol                   = string                 //"Tcp"
    source_port_range          = string                 // "*"
    destination_port_range     = optional(string)       // "*"
    destination_port_ranges    = optional(list(string)) //["9000", "9003", "1438", "1440", "1452"]
    source_address_prefix      = string                 //"*"
    destination_address_prefix = string                 //"*"
    description                = string
  }))
  default = []
}

variable "route_table_routes" {
  description = "list of route table routes"
  type = list(object({
    address_prefix = string
    name           = string
    next_hop_type  = string
  }))
  default = []
}

variable "log_analytics_retention" {
  description = "Rentention days for log analytics"
  type        = number
  default     = 30

}