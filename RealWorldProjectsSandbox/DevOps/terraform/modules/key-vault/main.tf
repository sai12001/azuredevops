locals {
  tags                   = merge(var.resource_group.tags, var.tags)
  global_devops_group_id = "d5b38d6b-b008-4881-a147-65c44f32e833"
  # Diagnostic Settings
  log_workspace = {
    name                = "${var.context.environment}-logs-${var.context.product}-workspace-${var.context.location_abbr}"
    resource_group_name = "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
  }
  key_vault_diagnostic_log_categories       = ["AuditEvent", "AzurePolicyEvaluationDetails"]
  
}


data "azurerm_client_config" "current" {}

data "azurerm_log_analytics_workspace" "law" {
  name                = local.log_workspace.name
  resource_group_name = local.log_workspace.resource_group_name
}

resource "azurerm_key_vault" "key_vault" {
  name                = var.key_vault_name
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  tags                = local.tags

  # TODO, review these values
  # enabled_for_disk_encryption = true
  # soft_delete_retention_days  = 7
  # purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get", "List"
    ]

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Purge"
    ]

    certificate_permissions = [
      "Get","Create","Delete","List","Purge","Update","Import"
    ]

    storage_permissions = [
      "Get"
    ]
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = local.global_devops_group_id

    key_permissions = [
      "Get", "List"
    ]

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Purge"
    ]
    certificate_permissions = [
      "Get","Create","Delete","List","Purge","Update","Import"
    ]

    storage_permissions = [
      "Get"
    ]
  }

  lifecycle {
    ignore_changes = [
      access_policy
    ]
    # prevent_destroy = true
  }
}
#----------------------------------------------------------------------------------------------------------
# Key Vault Diagnostic Setting
#----------------------------------------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "key_vault_diags" {
  name                           = format("%s-diags", azurerm_key_vault.key_vault.name)
  target_resource_id             = azurerm_key_vault.key_vault.id
  log_analytics_workspace_id     = data.azurerm_log_analytics_workspace.law.id
  dynamic "log" {
   for_each = local.key_vault_diagnostic_log_categories
   content {
     category = log.value
      retention_policy {
        days    = var.log_analytics_retention
        enabled = true
      }
    }
  }
  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }
  
  }
  lifecycle {
    ignore_changes = [log, log_analytics_workspace_id]
  }
  depends_on = [
    azurerm_key_vault.key_vault
  ]
}