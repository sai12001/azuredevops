terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.10.0"
    }
  }
  required_version = ">= 1.2.0"
  experiments      = [module_variable_optional_attrs]
}
