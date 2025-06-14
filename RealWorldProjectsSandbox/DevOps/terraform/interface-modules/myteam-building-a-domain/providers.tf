data "azurerm_key_vault" "infra_key_vault" {
  name                = "${var.context.environment}-kv-${var.context.product}-infra-${var.context.location_abbr}"
  resource_group_name = "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"

}

data "azurerm_key_vault_secret" "grafana_api_key" {
  name         = "ext-grafana-devops-api-key"
  key_vault_id = data.azurerm_key_vault.infra_key_vault.id
}

data "azurerm_key_vault_secret" "grafana_env_api_key" {
  name         = "grafana-api-key"
  key_vault_id = data.azurerm_key_vault.infra_key_vault.id
}

data "azurerm_key_vault_secret" "grafana_synthetic_token" {
  name         = "ext-grafana-synthetic-access-token"
  key_vault_id = data.azurerm_key_vault.infra_key_vault.id
}

data "grafana_cloud_stack" "cloud_stack" {
  provider = grafana.root
  slug     = "${var.context.environment}nextgen"
}

provider "grafana" {
  alias         = "root"
  cloud_api_key = data.azurerm_key_vault_secret.grafana_api_key.value
}

provider "grafana" {
  url             = data.grafana_cloud_stack.cloud_stack.url
  auth            = data.azurerm_key_vault_secret.grafana_env_api_key.value
  sm_url          = "https://synthetic-monitoring-api-au-southeast.grafana.net"
  sm_access_token = data.azurerm_key_vault_secret.grafana_synthetic_token.value
}
