variable "context" {
  description = "The environment context for this operation"
  type = object({
    product       = string
    environment   = string
    location      = string
    location_abbr = string
  })
}

variable "resource_group" {
  description = "Resoruce group object where this resource will deploy to, it suppose pass from resource group output"
  type = object({
    name     = string
    location = string
    tags     = map(string)
  })
}

variable "provision_internal_zone" {
  description = "Flag to tell if an internal zone will be provisioned"
  type        = bool
  default     = false
}

variable "provision_psql_zone" {
  description = "Flag to tell if an postgresql zone will be provisioned"
  type        = bool
  default     = false
}

variable "privatelink_dns_zones" {
  description = "The name for private dns zones"
  type = list(string)
  default = []
}

variable "vnet_config" {
  description = "The shared vnet configuration"
  type = object({
    name           = string
    resource_group = string
  })
}


variable "tags" {
  description = "Tags need to attach to this resource"
  type        = map(string)
  default     = {}
}
