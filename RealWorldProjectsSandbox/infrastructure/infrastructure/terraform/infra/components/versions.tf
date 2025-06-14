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
    acme = {
      source  = "vancluever/acme"
      version = "~> 2.10.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.10.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.28.0"
    }
    grafana = {
      source  = "grafana/grafana"
      version = "1.34.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "1.6.1"
    }
    azapi = {
      source  = "azure/azapi"
      version = "1.0.0"
    }
    opsgenie = {
      source  = "opsgenie/opsgenie"
      version = "0.6.18"
    }

  }
  required_version = ">= 1.2.0"
  experiments      = [module_variable_optional_attrs]
}
