variable "environment" {
  type        = string
  description = "Environment"
}

variable "domain_name" {
  type        = string
  description = "domain_name"
}

variable "AzureDataSourceID" {
  type        = string
  description = "AzureDataSourceID"
}

variable "app_service_plans" {
  description = "The App Service Plan Configurations"
  type = list(object({
    abbr_name      = string
    full_name      = string
    resource_group = string
  }))
}
