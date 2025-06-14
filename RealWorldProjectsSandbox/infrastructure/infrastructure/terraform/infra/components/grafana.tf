locals {
  grafana_dashboard_configs = jsondecode(file("${path.module}/dashboard_configs/grafana-configurations.json"))
}

###############################################################
# Dashboards
###############################################################

resource "grafana_dashboard" "grafana-apim-dashboard" {
  folder = data.grafana_folder.folder.id
  config_json = templatefile("./dashboard_templates/grafana-apim.json", {
    AzureDataSourceID = data.azurerm_key_vault_secret.grafana_datasource_id.value
    RESOURCE_GROUP    = "${var.environment}-rg-ng-infra-shared-eau"
    RESOURCE_NAME     = "${var.environment}-apim-ng-infra-shared"
    SUBSCRIPTION      = data.azurerm_subscription.current.subscription_id
  })
  overwrite = true
  depends_on = [
    grafana_folder.folders
  ]
}

resource "grafana_dashboard" "grafana-sqlmi-dashboard" {
  folder = data.grafana_folder.folder.id
  config_json = templatefile("./dashboard_templates/grafana-sqlmi.json", {
    AzureDataSourceID = data.azurerm_key_vault_secret.grafana_datasource_id.value
    RESOURCE_GROUP    = "${var.environment}-rg-ng-tbs-sql"
    RESOURCE_NAME     = "${var.environment}-sqlmi-ng-tbs"
    SUBSCRIPTION      = data.azurerm_subscription.current.subscription_id
  })
  overwrite = true
  depends_on = [
    grafana_folder.folders
  ]
}

resource "grafana_dashboard" "grafana-tbs-vm-dashboard" {
  folder = data.grafana_folder.folder.id
  config_json = templatefile("./dashboard_templates/grafana-tbsvm.json", {
    AzureDataSourceID = data.azurerm_key_vault_secret.grafana_datasource_id.value
    RESOURCE_GROUP    = "${var.environment}-rg-ng-tbs-eau"
    RESOURCE_NAME     = "${var.environment}-vm-ng-tbs-host-0"
    SUBSCRIPTION      = data.azurerm_subscription.current.subscription_id
  })
  overwrite = true
  depends_on = [
    grafana_folder.folders
  ]
}


resource "grafana_dashboard" "grafana-infra-summary-dashboard" {
  folder = data.grafana_folder.folder.id
  config_json = templatefile("./dashboard_templates/grafana_infra_summary.json", {
    AzureDataSourceID           = data.azurerm_key_vault_secret.grafana_datasource_id.value
    INFRA_SHARED_RESOURCE_GROUP = "${var.environment}-rg-ng-infra-shared-eau"
    SB_RESOURCE_NAME            = "${var.environment}-sb-ng-infra-shared-eau"
    SIGNALR_RESOURCE_NAME       = "${var.environment}-sigr-ng-infra"
    APIM_RESOURCE_NAME          = "${var.environment}-apim-ng-infra-shared"

    TBSVM_RESOURCE_GROUP     = "${var.environment}-rg-ng-tbs-eau"
    TBSVM_HOST_RESOURCE_NAME = "${var.environment}-vm-ng-tbs-host-0"
    TBSVM_IIS_RESOURCE_NAME  = "${var.environment}-vm-ng-tbs-iis-0"
    TBSVM_RMQ_RESOURCE_NAME  = "${var.environment}-vm-ng-tbs-rmq-0"

    TBS_SQLMI_RESOURCE_GROUP = "${var.environment}-rg-ng-tbs-sql"
    TBS_SQLMI_RESOURCE_NAME  = "${var.environment}-sqlmi-ng-tbs"

    NTRC_SQLMI_RESOURCE_GROUP = "${var.environment}-rg-ng-ntrc-shared-eau"
    NTRC_SQLMI_RESOURCE_NAME  = "${var.environment}-sqlmi-ng-ntrc"

    SUBSCRIPTION = data.azurerm_subscription.current.subscription_id
  })
  overwrite = true
  depends_on = [
    grafana_folder.folders
  ]
}

resource "grafana_dashboard" "grafana-replication-dashboard" {
  folder = data.grafana_folder.folder.id
  config_json = templatefile("./dashboard_templates/grafana-replication-dashboard.json", {
    AzureDataSourceID = data.azurerm_key_vault_secret.grafana_datasource_id.value
    SUBSCRIPTION      = data.azurerm_subscription.current.subscription_id
    DASHBOARD_NAME    = "Replication Dashboard"
    ENVIRONMENT       = var.environment

    # Racing
    RACING_RESOURCE_GROUP      = "${var.environment}-rg-ng-racing-shared-eau"
    RACING_RESOURCE_GROUP_DATA = "${var.environment}-rg-ng-racing-datatools-eau"

    RACING_RESOURCE_NAME_EHN     = "${var.environment}-ehn-ng-racing-eau"
    RACING_RESOURCE_NAME_DATA_AI = "${var.environment}-ai-ng-racing-datatools-eau"

    # Infra
    RESOURCE_GROUP_INFRA   = "${var.environment}-rg-ng-infra-shared-eau"
    RESOURCE_NAME_INFRA_SB = "${var.environment}-sb-ng-infra-shared-eau"

    # Account
    ACCOUNT_RESOURCE_GROUP    = "${var.environment}-rg-ng-account-shared-eau"
    ACCOUNT_RESOURCE_NAME_EHN = "${var.environment}-ehn-ng-account-eau"

    # BET
    BET_RESOURCE_GROUP        = "${var.environment}-rg-ng-bet-shared-eau"
    BET_RESOURCE_NAME_EHN     = "${var.environment}-ehn-ng-bet-eau"
    BET_RESOURCE_GROUP_DATA   = "${var.environment}-rg-ng-betdatatools-eng-eau"
    BET_RESOURCE_NAME_DATA_AI = "${var.environment}-ai-ng-betdatatools-eng-eau"

    # ACC
    ACC_RESOURCE_GROUP   = "${var.environment}-rg-ng-acc-dt-eau"
    ACC_RESOURCE_NAME_AI = "${var.environment}-ai-ng-acc-dt-eau"

    # BET History
    BETH_RESOURCE_GROUP   = "${var.environment}-rg-ng-bethistory-eng-eau"
    BETH_RESOURCE_NAME_AI = "${var.environment}-ai-ng-bethistory-eng-eau"
  })
  overwrite = true
  depends_on = [
    grafana_folder.folders
  ]
}

resource "grafana_dashboard" "grafana-redis-dashboard" {
  folder = data.grafana_folder.folder.id
  config_json = templatefile("./dashboard_templates/grafana-redis.json", {
    AzureDataSourceID = data.azurerm_key_vault_secret.grafana_datasource_id.value
    RESOURCE_GROUP    = "${var.environment}-rg-ng-infra-shared-eau"
    RESOURCE_NAME     = "${var.environment}-rdis-ng-infra-shared"
    SUBSCRIPTION      = data.azurerm_subscription.current.subscription_id
  })
  overwrite = true
  depends_on = [
    grafana_folder.folders
  ]
}

resource "grafana_dashboard" "grafana-databricks-dashboard" {
  folder = data.grafana_folder.folder.id
  config_json = templatefile("./dashboard_templates/grafana-databricks.json", {
    ENVIRONMENT               = var.environment
    AzureDataSourceID         = data.azurerm_key_vault_secret.grafana_datasource_id.value
    SUBSCRIPTION              = data.azurerm_subscription.current.subscription_id
    RESOURCE_GROUP            = "${var.environment}-rg-ng-infra-shared-eau"
    RESOURCE_NAME             = "${var.environment}-logs-ng-workspace-eau"
    DATABRICKS_MANAGED_RG     = "DATABRICKS-RG-${var.environment}-RG-NG-DATABRICKS-EAU"
    DRIVER_NODE_RESOURCE_NAME = local.grafana_dashboard_configs.grafana.databricks_driver_node_names["${var.environment}"]

  })
  overwrite = true
  depends_on = [
    grafana_folder.folders
  ]
}

resource "grafana_dashboard" "grafana-untagged-resource-dashboard" {
  folder = data.grafana_folder.folder.id
  config_json = templatefile("./dashboard_templates/grafana-unused-resources.json", {
    ENVIRONMENT       = var.environment
    AzureDataSourceID = data.azurerm_key_vault_secret.grafana_datasource_id.value
    SUBSCRIPTION      = data.azurerm_subscription.current.subscription_id
  })
  overwrite = true
  depends_on = [
    grafana_folder.folders
  ]
}

###############################################################
# ServiceBus Namespace Dashboard and Alerts
###############################################################

module "servicebus_namespace_grafana" {
  source        = "../../../../../DevOps/terraform/modules/service-bus/grafana"
  context       = local.context
  domain_name   = var.domain_name
  datasource_id = data.azurerm_key_vault_secret.grafana_datasource_id.value
  depends_on = [
    module.servicebus_namespace,
    grafana_folder.folders
  ]
}

###############################################################
# SignalR Dashboard and Alerts
###############################################################

module "signalr_grafana" {
  source        = "../../../../../DevOps/terraform/modules/signalr/grafana"
  context       = local.context
  domain        = var.domain_name
  team          = var.team_name
  datasource_id = data.azurerm_key_vault_secret.grafana_datasource_id.value
  depends_on = [
    module.signalr,
    grafana_folder.folders
  ]
}

###############################################################
# APIM Alert Rules
###############################################################
module "apim_alerts" {
  source          = "../../../../../DevOps/terraform/modules/grafana-alert-rules"
  datasource_uid  = data.azurerm_key_vault_secret.grafana_datasource_id.value
  environment     = var.environment
  folder_uid      = data.grafana_folder.folder.uid
  rule_group_name = "APIM | ${var.environment}-apim-ng-infra-shared"
  grafana_metric_alert = {
    Capacity = {
      subscription      = data.azurerm_subscription.current.subscription_id
      folderuid         = data.grafana_folder.folder.uid
      resourceGroup     = "${var.environment}-rg-ng-infra-shared-eau"
      resourceName      = "${var.environment}-apim-ng-infra-shared"
      metricNamespace   = "microsoft.apimanagement/service"
      alert_name        = "APIM Capacity > 75%"
      alert_summary     = "Critical | API Management Capacity > 75%"
      alert_description = "APIM Capacity Consumption > 75%"
      timefor           = "5m"
      interval_seconds  = 240
      domain            = "infra"
      team              = "cloudops"
      severity          = "P2"
      resource_type     = "apim"
      alert_type        = "Metrics"
      metricName        = "Capacity"
      dimensionFilters  = []
      metric_threshold  = 75
    }

    Requests4xxError = {
      subscription      = data.azurerm_subscription.current.subscription_id
      folderuid         = data.grafana_folder.folder.uid
      resourceGroup     = "${var.environment}-rg-ng-infra-shared-eau"
      resourceName      = "${var.environment}-apim-ng-infra-shared"
      metricNamespace   = "microsoft.apimanagement/service"
      alert_name        = "APIM Request 4xx Errors > 100"
      alert_summary     = "Critical | API Management APIM Request 4xx Errors > 100"
      alert_description = "APIM Request 4xx Errors > 100"
      no_data_state     = "OK"
      timefor           = "5m"
      interval_seconds  = 240
      domain            = "infra"
      team              = "cloudops"
      severity          = "P2"
      resource_type     = "apim"
      alert_type        = "Metrics"
      metricName        = "Requests"
      aggregation       = "Total"
      dimensionFilters = [{
        "dimension" = "BackendResponseCode"
        "filters"   = ["4"]
        "operator"  = "sw"
      }]
      metric_threshold = 100
    }

    Requests5xxError = {
      subscription      = data.azurerm_subscription.current.subscription_id
      folderuid         = data.grafana_folder.folder.uid
      resourceGroup     = "${var.environment}-rg-ng-infra-shared-eau"
      resourceName      = "${var.environment}-apim-ng-infra-shared"
      metricNamespace   = "microsoft.apimanagement/service"
      alert_name        = "APIM Request 5xx Errors > 10"
      alert_summary     = "Critical | API Management APIM Request 5xx Errors > 10"
      alert_description = "APIM Request 5xx Errors > 10"
      timefor           = "5m"
      no_data_state     = "OK"
      interval_seconds  = 240
      domain            = "infra"
      team              = "cloudops"
      severity          = "P1"
      resource_type     = "apim"
      alert_type        = "Metrics"
      aggregation       = "Total"
      metricName        = "Requests"
      dimensionFilters = [{
        "dimension" = "BackendResponseCode"
        "filters"   = ["5"]
        "operator"  = "sw"
      }]
      metric_threshold = 10
    }

  }
}

# ###############################################################
# # SQLMI Alert Rules
# ###############################################################

module "sqlmi_alerts" {
  source          = "../../../../../DevOps/terraform/modules/grafana-alert-rules"
  datasource_uid  = data.azurerm_key_vault_secret.grafana_datasource_id.value
  environment     = var.environment
  folder_uid      = data.grafana_folder.folder.uid
  rule_group_name = "SQLMI | ${var.environment}-sqlmi-ng-tbs"
  grafana_metric_alert = {
    avg_cpu_percent = {
      subscription      = data.azurerm_subscription.current.subscription_id
      folderuid         = data.grafana_folder.folder.uid
      resourceGroup     = "${var.environment}-rg-ng-tbs-sql"
      resourceName      = "${var.environment}-sqlmi-ng-tbs"
      metricNamespace   = "microsoft.sql/managedinstances"
      alert_name        = "SQLMI CPU Percentage > 75%"
      alert_summary     = "Critical | SQLMI CPU Percentage > 75%"
      alert_description = "SQLMI CPU Percentage > 75%"
      timefor           = "5m"
      interval_seconds  = 240
      domain            = "account"
      team              = "cloudops"
      severity          = "P1"
      resource_type     = "sqlmi"
      alert_type        = "Metrics"
      metricName        = "avg_cpu_percent"
      dimensionFilters  = []
      metric_threshold  = 75
    }

    # storage_space_used_mb = {
    #   subscription      = data.azurerm_subscription.current.subscription_id
    #   folderuid         = data.grafana_folder.folder.uid
    #   resourceGroup     = "${var.environment}-rg-ng-tbs-sql"
    #   resourceName      = "${var.environment}-sqlmi-ng-tbs"
    #   metricNamespace   = "microsoft.sql/managedinstances"
    #   alert_name        = "SQLMI High Storage Space Used > 90%"
    #   alert_summary     = "Critical | SQLMI High Storage Space Used > 90%"
    #   alert_description = "SQLMI SQLMI High Storage Space Used > 90%"
    #   timefor           = "5m"
    #   interval_seconds  = 240
    #   domain            = "account"
    #   team              = "cloudops"
    #   severity          = "P2"
    #   resource_type     = "sqlmi"
    #   alert_type        = "Metrics"
    #   metricName        = "storage_space_used_mb"
    #   dimensionFilters  = []
    #   metric_threshold  = 90
    # }

    # reserved_storage_mb = {
    #   subscription      = data.azurerm_subscription.current.subscription_id
    #   folderuid         = data.grafana_folder.folder.uid
    #   resourceGroup     = "${var.environment}-rg-ng-tbs-sql"
    #   resourceName      = "${var.environment}-sqlmi-ng-tbs"
    #   metricNamespace   = "microsoft.sql/managedinstances"
    #   alert_name        = "SQLMI Reserved Storage >"
    #   alert_summary     = "Critical | SQLMI Reserved Storage High"
    #   alert_description = "SQLMI Reserved Storage High"
    #   timefor           = "5m"
    #   interval_seconds  = 240
    #   domain            = "account"
    #   team              = "cloudops"
    #   severity          = "P1"
    #   resource_type     = "sqlmi"
    #   alert_type        = "Metrics"
    #   metricName        = "reserved_storage_mb"
    #   dimensionFilters  = []
    #   metric_threshold  = 75
    # }

  }
}

# ###############################################################
# # TBS VM Alert Rules
# ###############################################################

module "tbsvm_alerts" {
  for_each        = toset(["host-0", "iis-0", "rmq-0"])
  source          = "../../../../../DevOps/terraform/modules/grafana-alert-rules"
  datasource_uid  = data.azurerm_key_vault_secret.grafana_datasource_id.value
  environment     = var.environment
  folder_uid      = data.grafana_folder.folder.uid
  rule_group_name = "TBSVM | ${var.environment}-vm-ng-tbs-${each.key}"
  grafana_metric_alert = {
    cpu = {
      subscription      = data.azurerm_subscription.current.subscription_id
      folderuid         = data.grafana_folder.folder.uid
      resourceGroup     = "${var.environment}-rg-ng-tbs-eau"
      resourceName      = "${var.environment}-vm-ng-tbs-${each.key}"
      metricNamespace   = "microsoft.compute/virtualmachines"
      alert_name        = "VM ${each.key} CPU Consumption"
      alert_summary     = "Critical | VM ${each.key} CPU Consumption"
      alert_description = "VM ${each.key} CPU Consumption is High"
      timefor           = "5m"
      interval_seconds  = 240
      domain            = "infra"
      team              = "cloudops"
      severity          = "P1"
      resource_type     = "vm"
      alert_type        = "Metrics"
      aggregation       = "Average"
      metricName        = "Percentage CPU"
      dimensionFilters  = []
      metric_threshold  = 90
    }
  }
}

# ###############################################################
# # Redis Alert Rules
# ###############################################################

module "redis_alerts" {
  source          = "../../../../../DevOps/terraform/modules/grafana-alert-rules"
  datasource_uid  = data.azurerm_key_vault_secret.grafana_datasource_id.value
  environment     = var.environment
  folder_uid      = data.grafana_folder.folder.uid
  rule_group_name = "Redis | ${var.environment}-rdis-ng-infra-shared"
  grafana_metric_alert = {
    serverLoad = {
      subscription      = data.azurerm_subscription.current.subscription_id
      folderuid         = data.grafana_folder.folder.uid
      resourceGroup     = "${var.environment}-rg-ng-infra-shared-eau"
      resourceName      = "${var.environment}-rdis-ng-infra-shared"
      metricNamespace   = "microsoft.cache/redis"
      alert_name        = "Redis Cache Server Load"
      alert_summary     = "Critical | Redis Cache Server Load"
      alert_description = "Redis Cache Server Load is High"
      timefor           = "5m"
      interval_seconds  = 240
      domain            = "infra"
      team              = "cloudops"
      severity          = "P1"
      resource_type     = "rdis"
      alert_type        = "Metrics"
      aggregation       = "Average"
      metricName        = "serverLoad"
      dimensionFilters  = []
      metric_threshold  = 75
    }

    errors = {
      subscription      = data.azurerm_subscription.current.subscription_id
      folderuid         = data.grafana_folder.folder.uid
      resourceGroup     = "${var.environment}-rg-ng-infra-shared-eau"
      resourceName      = "${var.environment}-rdis-ng-infra-shared"
      metricNamespace   = "microsoft.cache/redis"
      alert_name        = "Redis Cache Error Avg Count"
      alert_summary     = "Critical | Redis Cache Error Avg Count"
      alert_description = "Redis Cache Error Avg Count is High"
      timefor           = "5m"
      interval_seconds  = 240
      domain            = "infra"
      team              = "cloudops"
      severity          = "P1"
      resource_type     = "rdis"
      alert_type        = "Metrics"
      aggregation       = "Average"
      metricName        = "errors"
      dimensionFilters  = []
      metric_threshold  = 10
    }
  }
}

# ###############################################################
# # Databricks Alert Rules
# ###############################################################
module "databricks_log_alerts" {
  count           = 1
  source          = "../../../../../DevOps/terraform/modules/grafana-log-alerts"
  datasource_uid  = data.azurerm_key_vault_secret.grafana_datasource_id.value
  folder_uid      = data.grafana_folder.folder.uid
  rule_group_name = "Databricks | ${var.environment}-ng-databricks-wspace"
  environment     = var.environment
  grafana_log_alerts = {
    JobFailedCount = {
      subscription      = data.azurerm_subscription.current.subscription_id
      folderuid         = data.grafana_folder.folder.uid
      resourceGroup     = "${var.environment}-rg-ng-infra-shared-eau"
      resourceName      = "${var.environment}-logs-ng-workspace-eau"
      alert_name        = "Databricks Job Failure count exceed the threshold "
      alert_summary     = "Databricks Job Failure count exceed the threshold of 500 failures"
      alert_description = "Exeception exceeded theshold of 500 exceptions"
      timefor           = "5m"
      interval_seconds  = 240
      domain            = "infra"
      team              = var.team_name
      severity          = "P2"
      resource_type     = "custom"
      alert_type        = "Logs"
      query             = local.grafana_dashboard_configs.grafana.databricks_alert_queries.failedJobCount
      threshold         = 500
    }
  }
}

module "databricks_driver_node_alerts" {
  source          = "../../../../../DevOps/terraform/modules/grafana-alert-rules"
  datasource_uid  = data.azurerm_key_vault_secret.grafana_datasource_id.value
  environment     = var.environment
  folder_uid      = data.grafana_folder.folder.uid
  rule_group_name = "Databricks Driver Node | ${var.environment}-ng-databricks-wspace"
  grafana_metric_alert = {
    cpu = {
      subscription      = data.azurerm_subscription.current.subscription_id
      folderuid         = data.grafana_folder.folder.uid
      resourceGroup     = "databricks-rg-${var.environment}-rg-ng-databricks-eau"
      resourceName      = local.grafana_dashboard_configs.grafana.databricks_driver_node_names["${var.environment}"]
      metricNamespace   = "microsoft.compute/virtualmachines"
      alert_name        = "Databricks Driver Node CPU Consumption"
      alert_summary     = "Critical | Databricks Driver Node CPU Consumption > 75%"
      alert_description = "Databricks Driver Node CPU Consumption is high"
      timefor           = "5m"
      interval_seconds  = 240
      domain            = "infra"
      team              = "cloudops"
      severity          = "P1"
      resource_type     = "vm"
      alert_type        = "Metrics"
      aggregation       = "Average"
      metricName        = "Percentage CPU"
      dimensionFilters  = []
      metric_threshold  = 75
      trigger_eval_type = "gt"
    }

    memory = {
      subscription      = data.azurerm_subscription.current.subscription_id
      folderuid         = data.grafana_folder.folder.uid
      resourceGroup     = "databricks-rg-${var.environment}-rg-ng-databricks-eau"
      resourceName      = local.grafana_dashboard_configs.grafana.databricks_driver_node_names["${var.environment}"]
      metricNamespace   = "microsoft.compute/virtualmachines"
      alert_name        = "Databricks Driver Node Memory Availability"
      alert_summary     = "Critical | Databricks Driver Node Available Memory < 25%"
      alert_description = "Databricks Driver Node Available Memroy is low"
      timefor           = "5m"
      interval_seconds  = 240
      domain            = "infra"
      team              = "cloudops"
      severity          = "P1"
      resource_type     = "vm"
      alert_type        = "Metrics"
      aggregation       = "Average"
      metricName        = "Available Memory Bytes"
      dimensionFilters  = []
      metric_threshold  = 25
      trigger_eval_type = "lt"
    }
  }
}

###############################################################
# TBS VMs Synthetic Testings
###############################################################
resource "grafana_synthetic_monitoring_check" "http" {
  for_each = toset([
    "https://${local.iis_url}/TBS.Messaging.API/MessagingService.svc",
    "https://${local.iis_url}/TBS.Domain.API/Service.svc",
    "https://${local.iis_url}/TBS.Search.API/SearchService.svc",
    "https://${local.iis_url}/TBS.Settler.API/Service1.svc",
    "https://${local.iis_url}/TBS.RiskManagement.API/RiskManagementService.svc",
    "https://${local.iis_url}/TBS.MarketingAdmin.API/PromotionService.svc",
    "https://${local.iis_url}/TBS.Reporting.API/ReportingService.svc",
    "https://${local.iis_url}/TBS.FeedAdmin.API/Service1.svc",
    "https://${local.iis_url}/TBS.Finance.API/FinanceService.svc",
    "https://${local.iis_url}/TBS.Admin.API/AdminService.svc",
    "https://${local.iis_url}/TBS.WebAdmin.API/WebAdminService.svc",
    "https://${local.iis_url}/TBS.BetIntercept.API/BetInterceptService.svc",
    "https://${local.iis_url}/TBS.ClientAdmin.API/ClientAdminService.svc"
  ])
  job     = "tbs"
  target  = each.key
  enabled = true
  probes = [
    data.grafana_synthetic_monitoring_probes.main.probes["${var.environment}_private_probe"],
  ]
  labels = merge(local.tags, {
    svc = "tbs"
  })
  settings {
    http {}
  }
}
