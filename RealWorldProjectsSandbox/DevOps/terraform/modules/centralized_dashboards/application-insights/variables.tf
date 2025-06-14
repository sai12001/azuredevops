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

variable "app_insights" {
  description = "The application insights Configurations"
  type = list(object({
    display_name   = string
    full_name      = string
    resource_group = string
  }))
}