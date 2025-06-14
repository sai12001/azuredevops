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

variable "cosmosdbs" {
  description = "The Cosmos DB Configurations"
  type = list(object({
    display_name   = string
    full_name      = string
    resource_group = string
  }))
}

variable "dashboard_name" {
  description = "Dashboard Name"
  type = string
}