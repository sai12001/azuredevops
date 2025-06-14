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

variable "psql_dns_zone_id" {
  description = "The private dns zone where the address will be resolved"
  type        = string

}
variable "psql_subnet_id" {
  description = "The subnet where the psql going to linked to"
  type        = string
}

variable "config" {
  description = "value"
  type = object({
    server_version    = optional(string)
    server_username   = optional(string)
    server_storage_mb = optional(number)
    server_sku        = optional(string)
  })
  default = {
    server_version    = "13"
    server_username   = "psqladmin"
    server_storage_mb = 32768
    server_sku        = "B_Standard_B1ms"
  }
}

variable "databases" {
  description = "Configuration for postgres sql databases in domain server"
  type = list(object({
    name      = string
    charset   = string
    collation = string
  }))
  default = []
}

variable "log_analytics_retention" {
  description = "Rentention days for log analytics"
  type        = number
  default     = 30

}
