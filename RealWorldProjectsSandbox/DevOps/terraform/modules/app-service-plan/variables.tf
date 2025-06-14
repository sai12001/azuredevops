
variable "context" {
  description = "The environment context for this operation"
  type = object({
    product       = string
    environment   = string
    location      = string
    location_abbr = string
  })
}

#TODO: validation, it must lower case and support alphabet and dash only
variable "app_service_plan_name" {
  description = "The app service plan name"
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
  description = "Tags need to attach to this resource group"
  type        = map(string)
  default     = {}
}

variable "per_site_scaling" {
  description = "Flag to determine the we want to use app service, by default is enabled"
  type        = bool
  default     = false
}

#TODO: validation, tier only support standard and premium (2,3), siz
variable "sku_name" {
  description = "Sku for app service plan"
  type        = string
  default     = "P1v3"
}

variable "domain" {
  description = "The logic domain this app service plan belongs to, racing, betplacement etc"
  type        = string
}

variable "team" {
  description = "The team related to this domain"
  type        = string
}
