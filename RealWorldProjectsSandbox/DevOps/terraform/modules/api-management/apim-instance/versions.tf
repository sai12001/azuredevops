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
  }
  required_version = ">= 1.2.0"
  experiments      = [module_variable_optional_attrs]
}
