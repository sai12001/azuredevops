terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.12.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "1.6.1"
    }
  }
  required_version = ">= 1.2.0"
  experiments      = [module_variable_optional_attrs]
}
provider "databricks" {
  azure_workspace_resource_id = azurerm_databricks_workspace.az_databricks_workspace.id
}

