
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

variable "wan_name" {
  description = "The name for virtual wan"
  type        = string
}

variable "wan_hubs" {
  description = "The hubs in virtual wan"
  type = map(object({
    address_prefix = string
  }))
}

variable "hub_connections" {
  type = map(object({
    hub_name = string
    vnet_id  = string
  }))
}
variable "firewall_private_ip" {
  description = "The Private IP Address of the Azure Firewall"
  type        = string
}

variable "default_route_table_id" {
  description = "Default Route Table ID"
  type        = string
}

variable "hub_route_tables" {
  type = map(object({
    hub_name = string
    labels   = list(string)
    route = object({
      name              = string
      destinations_type = string
      destinations      = list(string)
      next_hop_type     = string
      connection_name   = string
    })
  }))
  default = {}
}


variable "tags" {
  description = "Tags need to attach to this resource"
  type        = map(string)
  default     = {}
}
