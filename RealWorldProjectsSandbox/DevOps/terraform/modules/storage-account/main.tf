locals {
  tags = merge(var.resource_group.tags, var.tags)
  # Diagnostic Settings Config
  log_workspace = {
    name                = "${var.context.environment}-logs-${var.context.product}-workspace-${var.context.location_abbr}"
    resource_group_name = "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
  }
  storage_account_diagnostic_log_categories = ["StorageRead", "StorageWrite"]

}

data "azurerm_log_analytics_workspace" "law" {
  name                = local.log_workspace.name
  resource_group_name = local.log_workspace.resource_group_name
}

resource "azurerm_storage_account" "storage_account" {
  name                     = var.account_name
  resource_group_name      = var.resource_group.name
  location                 = var.resource_group.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  is_hns_enabled           = var.is_hns_enabled
  tags                     = local.tags
  dynamic "static_website" {
    for_each = var.enable_static_website ? [1] : []
    content {
      index_document = "index.html"
    }
  }
  blob_properties {
    dynamic "cors_rule" {
      for_each = var.cors_rules
      content {
        allowed_headers    = ["*"]
        allowed_methods    = cors_rule.value.allowed_methods
        allowed_origins    = cors_rule.value.allowed_origins
        max_age_in_seconds = cors_rule.value.max_age_InSeconds == null ? 86400 : cors_rule.value.max_age_InSeconds
        exposed_headers    = ["*"]
      }
    }
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      custom_domain
    ]
  }
}

resource "azurerm_storage_container" "azure_webjobs_secrets" {
  for_each              = { for container in var.containers : container.name => container }
  storage_account_name  = var.account_name
  name                  = each.key               # "azure-webjobs-secrets"
  container_access_type = each.value.access_type # "private"
  depends_on = [
    azurerm_storage_account.storage_account
  ]
}
resource "azurerm_storage_table" "tables" {
  for_each             = { for table in var.tables : table.name => table }
  storage_account_name = var.account_name
  name                 = each.key
  depends_on = [
    azurerm_storage_account.storage_account
  ]
}

resource "azurerm_storage_queue" "queues" {
  for_each             = { for queue in var.queues : queue.name => queue }
  storage_account_name = var.account_name
  name                 = each.key
  depends_on = [
    azurerm_storage_account.storage_account
  ]
}

resource "azurerm_storage_blob" "blobs" {
  for_each               = var.blobs
  name                   = each.value.name
  storage_account_name   = var.account_name
  storage_container_name = each.value.container_name
  type                   = each.value.type
  depends_on = [
    azurerm_storage_account.storage_account,
    azurerm_storage_container.azure_webjobs_secrets
  ]
  lifecycle {
    ignore_changes = [content_md5, content_type]
  }
}
data "azurerm_key_vault" "key_vault" {
  count               = var.target_keyvault_id == null ? 1 : 0
  name                = "${var.context.environment}-kv-${var.context.product}-${var.domain}-${var.context.location_abbr}"
  resource_group_name = "${var.context.environment}-rg-${var.context.product}-${var.domain}-shared-${var.context.location_abbr}"
}

resource "azurerm_key_vault_secret" "secret_storage_account_connection" {
  key_vault_id = var.target_keyvault_id == null ? data.azurerm_key_vault.key_vault[0].id : var.target_keyvault_id
  name         = "sta-connection-string-${var.account_name}"
  value        = azurerm_storage_account.storage_account.primary_connection_string
  lifecycle {
    ignore_changes = [
      key_vault_id
    ]
  }
}

#----------------------------------------------------------------------------------------------------------
# Storage Account Diagnostic Setting
#----------------------------------------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "storage_account_diags" {
  name                       = format("%s-diags", azurerm_storage_account.storage_account.name)
  target_resource_id         = azurerm_storage_account.storage_account.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.law.id
  # dynamic "log" {
  #  for_each = var.diagnostic_log_categories
  #  content {
  #    category = log.value
  #     retention_policy {
  #       days    = var.log_analytics_retention
  #       enabled = true
  #     }
  #   }
  # }
  metric {
    category = "Transaction"

    retention_policy {
      enabled = false
    }
  }
  depends_on = [
    azurerm_storage_account.storage_account
  ]
  lifecycle {
    ignore_changes = [metric, log_analytics_workspace_id]
  }
}
