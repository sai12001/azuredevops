
data "azurerm_subscription" "current" {
}

data "grafana_folder" "folder" {
  title = "amused-${local.domain_name}"
}

module "ai-logs-based-alerts" {
  source = "../../modules/grafana-log-based-alerts"

  count = length(var.grafana-ai-log-based-alerts.alerts) == 0 ? 0 : 1
  datasource_uid  = data.azurerm_key_vault_secret.grafana_datasource_id.value
  environment     = var.context.environment
  folder_uid      = data.grafana_folder.folder.uid
  rule_group_name = "logs | ${var.context.environment}-ai-ng-${local.solution_name}-eau"

  interval_seconds            = var.grafana-ai-log-based-alerts.interval_seconds
  resourceGroup               = "${var.context.environment}-rg-ng-${local.solution_name}-eau"
  resourceName                = "${var.context.environment}-ai-ng-${local.solution_name}-eau"
  subscription                = data.azurerm_subscription.current.subscription_id
  resource_type               = "ai"
  alert_type                  = "Logs"
  timefor                     = var.grafana-ai-log-based-alerts.timefor
  domain                      = local.domain_name
  grafana-ai-log-based-alerts = var.grafana-ai-log-based-alerts.alerts

}
