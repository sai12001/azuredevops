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

variable "key_vault_name" {
  description = "the key vault name"
  type        = string
}

variable "tags" {
  description = "Tags need to attach to this resource"
  type        = map(string)
  default     = {}
}

variable "log_analytics_retention" {
  description = "Rentention days for key value analytics"
  type        = number
  default     = 30

}
