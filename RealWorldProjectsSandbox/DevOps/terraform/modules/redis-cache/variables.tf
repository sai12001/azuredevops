
variable "context" {
  description = "The environment context for this operation"
  type = object({
    product       = string
    environment   = string
    location      = string
    location_abbr = string
  })
}

variable "capacity" {
  description = "capacity of the redis cache"
  type        = string
}

variable "domain" {
  description = "TODO"
  type        = string
}

variable "family" {
  description = "family of the redis cache"
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

variable "sku_name" {
  description = "sku of the redis cache"
  type        = string
}

variable "tags" {
  description = "Tags need to attach to this resource group"
  type        = map(string)
  default     = {}
}

variable "log_analytics_retention" {
  description = "Rentention days for log analytics"
  type        = number
  default     = 30

}