
variable "context" {
  description = "The environment context for this operation"
  type = object({
    product       = string
    environment   = string
    location      = string
    location_abbr = string
  })
}

variable "belong_to_team" {
  description = "The team who is responsible for this resource group"
  type        = string

}

#TODO: validation, it must lower case and support alphabet and dash only
variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}


variable "tags" {
  description = "Tags need to attach to this resource group"
  type        = map(string)
  default     = {}
}

variable "prevent_destroy" {
  description = "Delete protection"
  type        = bool
  default     = false
}

