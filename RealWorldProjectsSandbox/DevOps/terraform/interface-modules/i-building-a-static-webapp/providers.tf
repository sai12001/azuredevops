
provider "cloudflare" {
  api_token = data.azurerm_key_vault_secret.cf_api_token.value
}

data "azurerm_key_vault_secret" "cf_api_token" {
  name         = local.surge_cf_token_secret_name
  key_vault_id = data.azurerm_key_vault.infra_key_vault.id
}

