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