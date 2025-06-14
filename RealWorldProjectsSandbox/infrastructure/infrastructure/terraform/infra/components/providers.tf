terraform {
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

provider "azuread" {
}


provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

provider "cloudflare" {
  api_token = data.azurerm_key_vault_secret.cf_api_token.value
}

data "azurerm_key_vault_secret" "cf_api_token" {
  name         = local.cf_token_secret_name
  key_vault_id = data.azurerm_key_vault.infra_key_vault.id
}

data "azurerm_key_vault_secret" "grafana_api_key" {
  name         = "ext-grafana-devops-api-key"
  key_vault_id = data.azurerm_key_vault.infra_key_vault.id
}
data "azurerm_key_vault_secret" "grafana_synthetic_token" {
  name         = "ext-grafana-synthetic-access-token"
  key_vault_id = data.azurerm_key_vault.infra_key_vault.id
}

data "azurerm_key_vault_secret" "opsgenie_provider_apikey" {
  name         = "ext-opsgenie-provider-api-key"
  key_vault_id = data.azurerm_key_vault.infra_key_vault.id
}

provider "grafana" {
  alias         = "root"
  cloud_api_key = data.azurerm_key_vault_secret.grafana_api_key.value
}

provider "grafana" {
  url             = data.grafana_cloud_stack.cloud_stack.url
  auth            = grafana_api_key.api_key.key
  sm_url          = "https://synthetic-monitoring-api-au-southeast.grafana.net"
  sm_access_token = data.azurerm_key_vault_secret.grafana_synthetic_token.value
}

provider "databricks" {
}

provider "azapi" {
}

provider "opsgenie" {
  api_key = data.azurerm_key_vault_secret.opsgenie_provider_apikey.value
  api_url = "blackstream.app.opsgenie.com" # "api.eu.opsgenie.com" #default is api.opsgenie.com
}