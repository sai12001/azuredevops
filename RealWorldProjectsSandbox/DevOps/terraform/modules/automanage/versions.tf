terraform {
  required_providers {
    azapi = {
      source = "azure/azapi"
      version = "1.0.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.12.0"
    }
  }
} 