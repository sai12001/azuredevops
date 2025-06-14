variable "log_workspace" {
  description = "Resoruce group object where this resource will deploy to, it suppose pass from resource group output"
  type = object({
    resource_group_name = string
    name                = string
  })
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

variable "application_insights_name" {
  description = "The name for this application insights instance"
  type        = string
}

variable "tags" {
  description = "Tags need to attach to this resource group"
  type        = map(string)
  default     = {}
}

variable "application_type" {
  description = "The log type for this application insights, web etc"
  type        = string
  default     = "web"

}
variable "domain" {
  description = "TODO"
  type        = string
}

variable "team" {
  description = "TODO"
  type        = string
  default     = "cloudops"
}

variable "environment" {
  type        = string
  description = "environment"
}
