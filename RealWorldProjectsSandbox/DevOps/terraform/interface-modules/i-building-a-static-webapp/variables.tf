#TODO Add validation rules for this variable
variable "context" {
  description = "The environment context for this operation"
  type = object({
    product       = string
    environment   = string
    location      = string
    location_abbr = string
  })
}

variable "with_solution_configs" {
  description = "value"
  type = object({
    team_name     = string
    solution_name = string
    domain_name   = string
  })
  validation {
    condition     = can(regex("^[a-z]{2,12}(?:-[a-z]{2,12})*$", var.with_solution_configs.solution_name))
    error_message = "Solution name must follow format xxx[-xx] with max length of 12 before and after hypen(-)."
  }
  validation {
    condition     = contains(["frontend", "account", "racing", "bet", "promotion", "sport", "infra", "whatever", "core", "console"], var.with_solution_configs.domain_name)
    error_message = "Domain name must be one of following: account, racing, bet, promotion, sport, infra, core, console.[Case Sensitive]"
  }
  validation {
    condition     = length(var.with_solution_configs.team_name) < 24
    error_message = "Team name should not be more than 24 characters"
  }
}

variable "needs_static_website" {
  description = "configure the storage accounts  for static website"
  type = list(object({
    name                     = string
    account_tier             = optional(string)
    account_kind             = optional(string)
    account_replication_type = optional(string)
    sub_domain_name          = optional(string)
    #TODO to implement mapping
    base_domain = optional(string)
    containers = optional(list(object({
      name        = string
      access_type = string
      }))
    )
  }))
  validation {
    condition     = alltrue([for stawebsite in var.needs_static_website : contains(["StorageV2", "BlockBlobStorage"], coalesce(stawebsite.account_kind, "StorageV2"))])
    error_message = "static website account_kind only support StorageV2 and BlockBlobStorage"
  }
  default = []
}
