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

variable "tags" {
  description = "Tags need to attach to this resource"
  type        = map(string)
  default     = {}
}

variable "vnet" {
  description = "Vnet configuration"
  type = object({
    name          = string
    address_space = list(string)
    subnets = list(object({
      name     = string
      prefixes = list(string)
      delegation = optional(object({
        name = string
        service_delegation = object({
          name    = string
          actions = list(string)
        })
      }))
      service_endpoints = optional(list(string))
    }))
  })
}

variable "log_analytics_retention" {
  description = "Rentention days for log analytics"
  type        = number
  default     = 30

}