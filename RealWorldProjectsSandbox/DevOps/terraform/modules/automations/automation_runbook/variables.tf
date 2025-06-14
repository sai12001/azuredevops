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

variable "runbook_list" {
  type = map(object({
    name                    = string
    automation_account_name = string
    content                 = string
    runbook_type            = string
    description             = string
    log_progress            = bool
    log_verbose             = bool
  }))

}

variable "schedule_list" {
  type = map(object({
    automation_account_name = string
    frequency               = string
    interval                = number
    timezone                = string
    start_time              = string
    description             = string
    week_days               = optional(list(string))
    month_days              = optional(list(number))
  }))
}

variable "job_schedule_list" {
  type = map(object({
    automation_account_name = string
    schedule_name           = string
    runbook_name            = string
    vmname_list             = optional(list(string))
    parameters              = map(string)
  }))
}