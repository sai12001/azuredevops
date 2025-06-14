locals {
  tags = merge(var.resource_group.tags, var.tags)
  default_app_settings = {
    AzureWebJobsStorage                   = var.storage_account.connection_string
    WEBSITES_ENABLE_APP_SERVICE_STORAGE   = "false"
    APPINSIGHTS_INSTRUMENTATIONKEY        = var.application_insights.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = var.application_insights.connection_string
  }
  identity_type          = "SystemAssigned"
  function_app_name      = "${var.context.environment}-fnapp-${var.context.product}-${var.solution_name}-${var.function_app_name}-${var.context.location_abbr}"
  slot_name              = "stage"
  function_app_slot_name = "${local.function_app_name}-${local.slot_name}"
  fnapp_with_slots       = [local.function_app_name, local.function_app_slot_name]

  host_json_secret_content = {
    for slot in local.fnapp_with_slots : slot => {
      masterKey = {
        name      = "master"
        value     = random_password.master_key[slot].result
        encrypted = false
      }
      functionKeys = [
        {
          name      = "default"
          value     = random_password.function_key[slot].result
          encrypted = false
        }
      ]
      systemKeys = []
    }
  }
  secure_settings_expanded = { for setting in var.secure_settings : setting.config_name => "@Microsoft.KeyVault(SecretUri=https://${var.context.environment}-kv-${var.context.product}-${setting.domain}-${var.context.location_abbr}.azure.net/secrets/${setting.secret_name})" }

  connectionstrings_expanded = { for connection in var.connection_strings : connection.config_name => {
    name  = connection.config_name
    type  = connection.type
    value = "@Microsoft.KeyVault(SecretUri=https://${var.context.environment}-kv-${var.context.product}-${connection.domain}-${var.context.location_abbr}.azure.net/secrets/${connection.secret_name})"
  } }

  app_settings     = merge(local.default_app_settings, var.app_settings, local.secure_settings_expanded)
  extra_domain_kvs = distinct(concat([for setting in var.secure_settings : setting.domain if setting.domain != var.domain]))
  # Diagnostic Settings
  log_workspace = {
    name                = "${var.context.environment}-logs-${var.context.product}-workspace-${var.context.location_abbr}"
    resource_group_name = "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
  }
  fnapps_diagnostic_log_categories = ["FunctionAppLogs"]

  access_rules = [for r in var.access_rules : {
    action                    = r.action
    name                      = r.name
    priority                  = r.priority
    headers                   = []
    service_tag               = try(r.service_tag, null)
    ip_address                = try(r.ip_address, null)
    virtual_network_subnet_id = try(r.virtual_network_subnet_id, null)
  }]

}

data "azurerm_key_vault" "key_vault" {
  count               = var.target_keyvault_id == null ? 1 : 0
  name                = "${var.context.environment}-kv-${var.context.product}-${var.domain}-${var.context.location_abbr}"
  resource_group_name = "${var.context.environment}-rg-${var.context.product}-${var.domain}-shared-${var.context.location_abbr}"
}

data "azurerm_key_vault" "extra_key_vaults" {
  for_each            = toset(local.extra_domain_kvs)
  name                = "${var.context.environment}-kv-${var.context.product}-${each.key}-${var.context.location_abbr}"
  resource_group_name = "${var.context.environment}-rg-${var.context.product}-${each.key}-shared-${var.context.location_abbr}"
}

data "azurerm_log_analytics_workspace" "law" {
  name                = local.log_workspace.name
  resource_group_name = local.log_workspace.resource_group_name
}

resource "random_password" "master_key" {
  for_each         = toset(local.fnapp_with_slots)
  length           = 48
  special          = true
  override_special = "/="
}

resource "random_password" "function_key" {
  for_each         = toset(local.fnapp_with_slots)
  length           = 48
  special          = true
  override_special = "/="
}


resource "random_string" "host_ids" {
  for_each = toset(["prod", "stage"])
  length   = 32
  special  = false
  lower    = true
  upper    = false
  number   = true
}

resource "azurerm_key_vault_secret" "fnapp_master_code_secret" {
  for_each     = toset(local.fnapp_with_slots)
  key_vault_id = var.target_keyvault_id == null ? data.azurerm_key_vault.key_vault[0].id : var.target_keyvault_id
  name         = "fnapp-master-code-${each.value}"
  value        = random_password.master_key[each.value].result
  lifecycle {
    ignore_changes = [
      key_vault_id
    ]
  }
}

resource "azurerm_key_vault_secret" "fnapp_default_code_secret" {
  for_each     = toset(local.fnapp_with_slots)
  key_vault_id = var.target_keyvault_id == null ? data.azurerm_key_vault.key_vault[0].id : var.target_keyvault_id
  name         = "fnapp-default-code-${each.value}"
  value        = random_password.function_key[each.value].result
  lifecycle {
    ignore_changes = [
      key_vault_id
    ]
  }
}

resource "azurerm_storage_blob" "host_file" {
  for_each               = toset(local.fnapp_with_slots)
  name                   = "${each.value}/host.json"
  storage_account_name   = var.storage_account.name
  storage_container_name = "azure-webjobs-secrets"
  type                   = "Block"
  content_type           = "application/json"
  source_content         = jsonencode(local.host_json_secret_content[each.value])

  lifecycle {
    ignore_changes = [parallelism, size, content_md5, content_type]
  }
}

resource "azurerm_linux_function_app" "linux_fnapp" {
  name                 = local.function_app_name
  resource_group_name  = var.resource_group.name
  location             = var.resource_group.location
  storage_account_name = var.storage_account.name
  service_plan_id      = var.app_service_plan_id
  tags                 = local.tags

  site_config {
    always_on    = true
    worker_count = var.worker_count
    dynamic "cors" {
      for_each = var.cors_allowed_origins

      content {
        allowed_origins = var.cors_allowed_origins
      }
    }

    ip_restriction              = local.access_rules
    scm_use_main_ip_restriction = true

    dynamic "app_service_logs" {
      for_each = var.enable_local_logging == true ? [1] : []
      content {
        disk_quota_mb = 50
      }
    }
  }

  app_settings = merge(local.app_settings, {
    AzureFunctionsWebHost__hostid = random_string.host_ids["prod"].result
  })

  identity {
    type = local.identity_type
  }
  lifecycle {
    ignore_changes = [
      site_config[0].application_insights_connection_string,
      site_config[0].application_insights_key,
      site_config[0].application_stack,
      storage_account_access_key,
      app_settings
    ]
  }
}

# resource "azurerm_private_endpoint" "app_private_endpoints" {
#   name                = lower("link-${local.function_app_name}")
#   resource_group_name = var.resource_group.name
#   location            = var.resource_group.location
#   subnet_id           = var.privatelink.subnet_id

#   private_service_connection {
#     private_connection_resource_id = azurerm_linux_function_app.linux_fnapp.id
#     name                           = lower(local.function_app_name)
#     subresource_names              = ["sites"]
#     is_manual_connection           = false
#   }

#   private_dns_zone_group {
#     name                 = "private-dns"
#     private_dns_zone_ids = [var.privatelink.private_dns_zone_id]
#   }
# }


resource "azurerm_linux_function_app_slot" "linux_fnapp_slot" {
  name                 = local.slot_name
  storage_account_name = var.storage_account.name
  function_app_id      = azurerm_linux_function_app.linux_fnapp.id
  tags                 = local.tags

  site_config {
    always_on    = true
    worker_count = var.worker_count
    dynamic "cors" {
      for_each = var.cors_allowed_origins

      content {
        allowed_origins = var.cors_allowed_origins
      }
    }

    health_check_path           = var.health_check_path
    ip_restriction              = local.access_rules
    scm_use_main_ip_restriction = true

    dynamic "app_service_logs" {
      for_each = var.enable_local_logging == true ? [1] : []
      content {
        disk_quota_mb = 50
      }
    }
  }

  app_settings = merge(local.app_settings, {
    AzureFunctionsWebHost__hostid = random_string.host_ids["stage"].result
  })
  dynamic "connection_string" {
    for_each = local.connectionstrings_expanded
    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  identity {
    type = local.identity_type
  }
  lifecycle {
    ignore_changes = [
      site_config[0].application_insights_connection_string,
      site_config[0].application_insights_key,
      site_config[0].application_stack,
      storage_account_access_key,
    ]
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "regional_vnet_connection" {
  count          = var.subnet_id == "" ? 0 : 1
  app_service_id = azurerm_linux_function_app.linux_fnapp.id
  subnet_id      = var.subnet_id
}

resource "azurerm_app_service_slot_virtual_network_swift_connection" "regional_vnet_connection_staging_slot" {
  count          = var.subnet_id == "" ? 0 : 1
  slot_name      = azurerm_linux_function_app_slot.linux_fnapp_slot.name
  app_service_id = azurerm_linux_function_app.linux_fnapp.id
  subnet_id      = var.subnet_id
}

locals {
  all_key_vault_ids = merge({ for key, data in data.azurerm_key_vault.extra_key_vaults : "${key}" => data.id }, { "${var.domain}" = var.target_keyvault_id == null ? data.azurerm_key_vault.key_vault[0].id : var.target_keyvault_id })
}

resource "azurerm_key_vault_access_policy" "app_access" {
  for_each     = local.all_key_vault_ids
  key_vault_id = each.value
  tenant_id    = azurerm_linux_function_app.linux_fnapp.identity[0].tenant_id
  object_id    = azurerm_linux_function_app.linux_fnapp.identity[0].principal_id
  secret_permissions = [
    "Get", "List"
  ]
  lifecycle {
    ignore_changes = [
      key_vault_id
    ]
  }
}

resource "azurerm_key_vault_access_policy" "app_slot_access" {
  # for_each     = toset(distinct(concat(values(data.azurerm_key_vault.extra_key_vaults), [data.azurerm_key_vault.key_vault.id])))
  for_each     = local.all_key_vault_ids
  key_vault_id = each.value
  tenant_id    = azurerm_linux_function_app_slot.linux_fnapp_slot.identity[0].tenant_id
  object_id    = azurerm_linux_function_app_slot.linux_fnapp_slot.identity[0].principal_id
  secret_permissions = [
    "Get", "List"
  ]
  lifecycle {
    ignore_changes = [
      key_vault_id
    ]
  }
}

module "apim_named_value" {
  source         = "../api-management/named-value"
  count          = var.exposed_to_apim ? 1 : 0
  resource_group = var.resource_group
  context        = var.context
  domain         = var.domain
  named_values = {
    "fnkey-${var.domain}-${var.solution_name}-${var.function_app_name}" = {
      is_secret = true
      secret_id = azurerm_key_vault_secret.fnapp_default_code_secret[local.function_app_name].versionless_id
    }
  }
}

#----------------------------------------------------------------------------------------------------------
# Function App Diagnostic Setting
#----------------------------------------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "fnapp_diags" {
  name                       = format("%s-diags", azurerm_linux_function_app.linux_fnapp.name)
  target_resource_id         = azurerm_linux_function_app.linux_fnapp.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.law.id
  #Placeholder to choose log categories
  dynamic "log" {
    for_each = local.fnapps_diagnostic_log_categories
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
  depends_on = [
    azurerm_linux_function_app.linux_fnapp
  ]
  lifecycle {
    ignore_changes = [log, log_analytics_workspace_id]
  }
}

