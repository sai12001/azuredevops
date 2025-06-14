terraform {
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

provider "cloudflare" {
  api_token = data.azurerm_key_vault_secret.cf_api_token.value
}

data "azurerm_key_vault" "global_key_vault" {
  name                = "global-kv-bs-infra-eau"
  resource_group_name = "global-rg-blackstream-infra-shared-eau"
}

data "azurerm_key_vault_secret" "cf_api_token" {
  name         = local.cf_token_secret_name
  key_vault_id = data.azurerm_key_vault.global_key_vault.id
}