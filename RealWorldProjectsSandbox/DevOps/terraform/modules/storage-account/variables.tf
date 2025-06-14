variable "resource_group" {
  description = "Resoruce group object where this resource will deploy to, it suppose pass from resource group output"
  type = object({
    name          = string
    tags          = map(string)
    location      = string
    location_abbr = string
  })
}

variable "domain" {
  description = "TODO"
  type        = string
}

variable "context" {
  description = "The environment context for this operation"
  type = object({
    product       = string
    environment   = string
    location      = string
    location_abbr = string
  })
}


# TODO validation for access to certain list
variable "containers" {
  description = "The containers need to be in this storage account"
  type = list(object({
    name        = string
    access_type = string
  }))
  default = []
}

variable "tables" {
  description = "TODO"
  type = list(object({
    name = string
  }))
  default = []
}

variable "queues" {
  description = "TODO"
  type = list(object({
    name = string
  }))
  default = []
}

variable "blobs" {
  description = "The blobs required to be added in the containers"
  type = map(object({
    name           = string,
    container_name = string,
    type           = string
  }))
  default = {}
}

# TODO: Validation, must be less than x characters
variable "account_name" {
  description = "the core storage account name where prefix and suffix will be applied to"
  type        = string
}
variable "account_tier" {
  description = "TODO"
  type        = string
  default     = "Standard"

}
variable "account_replication_type" {
  description = "TODO"
  type        = string
  default     = "LRS"
}
variable "is_hns_enabled" {
  description = "Enables Hierarchical namespace and unlock capabilities such as file and directory-level security. Also, know as Azure Data Lake Storage Gen2"
  type        = bool
  default     = "false"
}
variable "tags" {
  description = "Tags need to attach to this resource group"
  type        = map(string)
  default     = {}
}

variable "target_keyvault_id" {
  description = "Specfic the key vault to use"
  type        = string
  default     = null
}

variable "log_analytics_retention" {
  description = "Rentention days for log analytics"
  type        = number
  default     = 30
}

variable "enable_static_website" {
  description = "Flag to enable static website for this storage account"
  type        = bool
  default     = false
}

variable "cors_rules" {
  description = "A List of origins which should be able to make cross-origin calls"
  type = list(object({
    allowed_methods   = list(string)
    allowed_origins   = list(string)
    max_age_InSeconds = optional(number)
  }))
  validation {
    condition = alltrue([for cors_rule in var.cors_rules : (
      alltrue([for allowed_method in cors_rule.allowed_methods : contains(["GET", "HEAD", "MERGE", "POST", "PUT"], allowed_method)])
    )])
    error_message = "allowed must be the following: GET, HEAD, MERGE, POST, PUT "
  }
  default = []
}
