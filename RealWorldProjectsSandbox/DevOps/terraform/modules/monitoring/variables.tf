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

variable "log_analytics_retention" {
  type        = number
  description = "Log Analytics log retention in days 30 - 730."
}

variable "internet_ingestion_enabled" {
  type        = bool
  description = "Should the Log Analytics Workspace support ingestion over the Public Internet"
  default     = false
}

variable "internet_query_enabled" {
  type        = bool
  description = "Should the Log Analytics Workspace support querying over the Public Internet"
  default     = false
}