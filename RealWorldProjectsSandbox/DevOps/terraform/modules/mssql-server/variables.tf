variable "context" {
  description = "The environment context for this operation"
  type = object({
    product       = string
    environment   = string
    location      = string
    location_abbr = string
  })
}

variable "domain" {
  description = "TODO"
  type        = string
}
variable "team" {
  description = "TODO"
  type        = string
}

variable "resource_group" {
  description = "Resoruce group object where this resource will deploy to, it suppose pass from resource group output"
  type = object({
    name     = string
    location = string
    tags     = map(string)
  })
}

variable "tags" {
  description = "Tags need to attach to this resource"
  type        = map(string)
  default     = {}
}

variable "sql_databases" {
  description = "Config for Databases"
  type = list(
    object(
      {
        name           = string
        collation      = string
        license_type   = string
        max_size_gb    = number
        read_scale     = optional(bool)
        sku_name       = string
        zone_redundant = optional(bool)
    })
  )
}

variable "sql_version" {
  type = string
}

variable "sql_admin_name" {
  type = string
}

variable "privatelink_subnet_id" {
  type = string
}

variable "privatelink_private_dns_zone_id" {
  type = string
}

variable "public_network_access_enabled" {
  type    = bool
  default = false
}

variable "vnet_config" {
  description = "The shared vnet configuration"
  type = object({
    name           = string
    resource_group = string
  })
}

variable "subnet_name" {
  type        = string
  description = "Subnet to be used by MS-SQL"
}