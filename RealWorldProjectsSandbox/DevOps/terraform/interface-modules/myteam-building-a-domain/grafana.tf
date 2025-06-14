locals {
  grafana_dashboard_configs = jsondecode(file("${path.module}/dashboard_configs/racing-domain-grafana-configurations.json"))
}

data "azurerm_subscription" "current" {
}

data "grafana_folder" "folder" {
  title = "amused-${local.domain_name}"
}

resource "grafana_dashboard" "grafana_summary_racing" {
  count  = local.domain_name == "racing" ? 1 : 0
  folder = data.grafana_folder.folder.id
  config_json = templatefile("${path.module}/dashboard_templates/grafana_racing_summary.json", {
    AzureDataSourceID = data.azurerm_key_vault_secret.grafana_datasource_id.value
    ENVIRONMENT       = var.context.environment
    SUBSCRIPTION      = data.azurerm_subscription.current.subscription_id

    RACING_DOMAIN_RESOURCE_STORAGE = local.grafana_dashboard_configs.grafana.storage_account_names["${var.context.environment}"]

    RACING_DATATOOL_RESOURCE_GROUP = "${var.context.environment}-rg-ng-racing-datatools-eau"
    RACING_DATATOOL_RESOURCE_AI    = "${var.context.environment}-ai-ng-racing-datatools-eau"
    RACING_DATATOOL_RESOURCE_ASP   = "${var.context.environment}-asp-ng-racing-datatools-eau"

    RACING_SHARED_RESOURCE_GROUP = "${var.context.environment}-rg-ng-racing-shared-eau"
    RACING_RESOURCE_EHN          = "${var.context.environment}-ehn-ng-racing-eau"

    RACING_RESOURCE_PSQL = "${var.context.environment}-psql-racing-shared"

    RACING_RESOURCE_DOCDB = "${var.context.environment}-docdb-ng-racing-eau"

    RACING_ENGINE_RESOURCE_ASP = "${var.context.environment}-asp-ng-racing-engine-eau"
    RACING_FEED_RESOURCE_ASP   = "${var.context.environment}-asp-ng-racing-feeds-eau"

    RACING_ENG_RESOURCE_GROUP = "${var.context.environment}-rg-ng-racing-eng-eau"
    RACING_ENG_RESOURCE_AI    = "${var.context.environment}-ai-ng-racing-eng-eau"

    RACING_XL_RESOURCE_GROUP = "${var.context.environment}-rg-ng-racing-xl-eau"
    RACING_XL_RESOURCE_AI    = "${var.context.environment}-ai-ng-racing-xl-eau"
    RACING_XL_RESOURCE_ASP   = "${var.context.environment}-asp-ng-racing-xl-eau"

    TABINGRESS_ENG_RESOURCE_GROUP = "${var.context.environment}-rg-ng-tabingress-eng-eau"
    TABINGRESS_ENG_RESOURCE_AI    = "${var.context.environment}-ai-ng-tabingress-eng-eau"

    DOINGRESS_ENG_RESOURCE_GROUP = "${var.context.environment}-rg-ng-doingress-eng-eau"
    DOINGRESS_ENG_RESOURCE_AI    = "${var.context.environment}-ai-ng-doingress-eng-eau"

    SIGR_ENG_RESORUCE_GROUP = "${var.context.environment}-rg-ng-signalr-eng-eau"
    SIGR_ENG_RESOURCE_AI    = "${var.context.environment}-ai-ng-signalr-eng-eau"

    DOHANDLER_ENG_RESOURCE_GROUP = "${var.context.environment}-rg-ng-dohandler-eng-eau"
    DOHANDLER_ENG_RESOURCE_AI    = "${var.context.environment}-ai-ng-dohandler-eng-eau"

    TBSCRUD_ENG_RESOURCE_GROUP = "${var.context.environment}-rg-ng-tbscrud-eng-eau"
    TBSCRUD_ENG_RESOURCE_AI    = "${var.context.environment}-ai-ng-tbscrud-eng-eau"

  })
  overwrite = true
}

resource "grafana_dashboard" "grafana_summary_account" {
  count  = local.domain_name == "account" ? 1 : 0
  folder = data.grafana_folder.folder.id
  config_json = templatefile("${path.module}/dashboard_templates/grafana_summary_account.json", {
    AzureDataSourceID = data.azurerm_key_vault_secret.grafana_datasource_id.value
    ENVIRONMENT       = var.context.environment
    SUBSCRIPTION      = data.azurerm_subscription.current.subscription_id

    RESOURCE_GROUP = "${var.context.environment}-rg-ng-racing-shared-eau"
    RESOURCE_NAME  = "${var.context.environment}-ehn-ng-racing-eau"

    ACCOUNT_RESOURCE_GROUP   = "${var.context.environment}-rg-ng-account-shared-eau"
    ACCOUNT_RESOURCE_PSQL    = "${var.context.environment}-psql-account-shared"
    ACCOUNT_RESOURCE_EHN     = "${var.context.environment}-ehn-ng-account-eau"
    ACCOUNT_RESOURCE_ASP     = "${var.context.environment}-asp-ng-account-datatools-eau"
    ACCOUNT_RESOURCE_ASP_ENG = "${var.context.environment}-asp-ng-account-engine-eau"
    ACCOUNT_RESOURCE_ASP_XL  = "${var.context.environment}-asp-ng-account-xl-eau"

    ACCOUNT_XL_RESOURCE_GROUP = "${var.context.environment}-rg-ng-account-xl-eau"
    ACCOUNT_XL_RESOURCE_FNAPP = "${var.context.environment}-fnapp-ng-account-xl-api-eau"

    ACCOUNT_SF_RESOURCE_GROUP = "${var.context.environment}-rg-ng-account-salesforce-eau"
    ACCOUNT_SF_RESOURCE_FNAPP = "${var.context.environment}-fnapp-ng-account-salesforce-engine-eau"

    BET_RESOURCE_GROUP    = "${var.context.environment}-rg-ng-bet-xl-eau"
    BET_RESOURCE_AI       = "${var.context.environment}-ai-ng-bet-xl-eau"
    BET_RESOURCE_FNAPP_XL = "${var.context.environment}-fnapp-ng-bet-xl-api-eau"

    INFRA_RESOURCE_GROUP = "${var.context.environment}-rg-ng-infra-shared-eau"
    INFRA_RESOURCE_SB    = "${var.context.environment}-sb-ng-infra-shared-eau"
    INFRA_RESOURCE_SIGR  = "${var.context.environment}-sigr-ng-infra"

    DOINGRESS_RESOURCE_GROUP    = "${var.context.environment}-rg-ng-doingress-eng-eau"
    DOINGRESS_RESOURCE_COSMOSDB = "${var.context.environment}-docdb-ng-doingress-eng-eau"

  })
  overwrite = true
}

resource "grafana_dashboard" "grafana_summary_bet" {
  count  = local.domain_name == "bet" ? 1 : 0
  folder = data.grafana_folder.folder.id
  config_json = templatefile("${path.module}/dashboard_templates/grafana_summary_bet.json", {
    AzureDataSourceID = data.azurerm_key_vault_secret.grafana_datasource_id.value
    ENVIRONMENT       = var.context.environment
    SUBSCRIPTION      = data.azurerm_subscription.current.subscription_id

    BET_PLACE_RESOURCE_GROUP     = "${var.context.environment}-rg-ng-betplacement-eng-eau"
    BET_PLACE_RESOURCE_AI        = "${var.context.environment}-ai-ng-betplacement-eng-eau"
    BET_PLACE_RESOURCE_FNAPP_API = "${var.context.environment}-fnapp-ng-betplacement-eng-api-eau"

    BET_INTERCEPT_RESOURCE_GROUP = "${var.context.environment}-rg-ng-betintercept-eng-eau"
    BET_INTERCEPT_RESOURCE_fnapp = "${var.context.environment}-fnapp-ng-betintercept-eng-api-eau"

    BET_RESOURCE_GROUP        = "${var.context.environment}-rg-ng-bet-xl-eau"
    BET_RESOURCE_FNAPP_XL     = "${var.context.environment}-fnapp-ng-bet-xl-api-eau"
    BET_SHARED_RESOURCE_GROUP = "${var.context.environment}-rg-ng-bet-shared-eau"

    BET_SHARED_RESOURCE_PSQL  = "${var.context.environment}-psql-bet-shared"
    BET_SHARED_RESOURCE_AI_XL = "${var.context.environment}-ai-ng-bet-xl-eau"
    BET_SHARED_RESOURCE_EHN   = "${var.context.environment}-ehn-ng-bet-eau"

    PAYMENT_RESOURCE_GROUP = "${var.context.environment}-rg-ng-payment-eng-eau"
    PAYMENT_RESOURCE_DOCDB = "${var.context.environment}-docdb-ng-payment-eng-eau"

    INFRA_SHARED_RESOURCE_GROUP = "${var.context.environment}-rg-ng-infra-shared-eau"
    INFRA_SHARED_RESOURCE_SB    = "${var.context.environment}-sb-ng-infra-shared-eau"

    AI_BET_DATA_RESOURCE_GROUP = "${var.context.environment}-rg-ng-betdatatools-eng-eau"
    BET_DATA_RESOURCE_AI       = "${var.context.environment}-ai-ng-betdatatools-eng-eau"

    BET_HISTORY_RESOURCE_GROUP = "${var.context.environment}-rg-ng-bethistory-eng-eau"
    BET_HISTORY_RESOURCE_AI    = "${var.context.environment}-ai-ng-bethistory-eng-eau"

  })
  overwrite = true
}
