###############################################################
# Data Sources
###############################################################

data "azurerm_key_vault_secret" "opsgenie_apikey_cloudops" {
  count        = var.environment == "prd" ? 1 : 0
  name         = "ext-opsgenie-cloudops-api-key"
  key_vault_id = data.azurerm_key_vault.infra_key_vault.id
}

###############################################################
# Grafana Contact Point For Opsgenie
###############################################################

resource "grafana_contact_point" "opsgenie_cloudops" {
  count = var.environment == "prd" ? 1 : 0
  name  = "Opsgenie-[${var.environment}]-CloudOps"
  opsgenie {
    api_key                 = data.azurerm_key_vault_secret.opsgenie_apikey_cloudops[0].value
    message                 = "{{ template \"generalmessage\" .}}"
    disable_resolve_message = false
    auto_close              = true
    description             = "Grafana contact point for Opsginie CloudOps Team"
    send_tags_as            = "tags"
    override_priority       = true
  }
}

###############################################################
# Grafana Notification Policy For Opsgenie
###############################################################

resource "grafana_notification_policy" "opsgenie_cloudops_policy" {
  count         = var.environment == "prd" ? 1 : 0
  group_by      = ["team"]
  contact_point = grafana_contact_point.opsgenie_cloudops[0].name

  group_wait      = "45s"
  group_interval  = "6m"
  repeat_interval = "30m"

  dynamic "policy" {
    for_each = toset(["infra", "account", "bet", "sport", "promotion", "console", "racing"])
    content {
      matcher {
        label = "domain"
        match = "="
        value = policy.key
      }
      contact_point = grafana_contact_point.opsgenie_cloudops[0].name
      group_by      = ["team", "og_priority", "domain", "resource_type", "environment"]
    }
  }

  depends_on = [
    grafana_contact_point.opsgenie_cloudops
  ]
}