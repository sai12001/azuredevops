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

variable "resource_group" {
  description = "Resoruce group object where this resource will deploy to, it suppose pass from resource group output"
  type = object({
    name     = string
    tags     = map(string)
    location = string
  })
}

variable "named_values" {
  description = "TODO"
  type = map(object({
    is_secret        = bool
    plain_text_value = optional(string)
    secret_id        = optional(string)
  }))
}

variable "tags" {
  description = "Tags need to attach to this resource"
  type        = map(string)
  default     = {}
}
