locals {
  tags = merge(var.resource_group.tags, var.tags)
  default_app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE   = "false"
    APPINSIGHTS_INSTRUMENTATIONKEY        = var.application_insights.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = var.application_insights.connection_string
  }
  identity_type     = "SystemAssigned"
  webapp_name       = "${var.context.environment}-webapp-${var.context.product}-${var.solution_name}-${var.webapp_name}-${var.context.location_abbr}"
  slot_name         = "stage"
  webapp_slot_name  = "${local.webapp_name}-${local.slot_name}"
  webapp_with_slots = [local.webapp_name, local.webapp_slot_name]

  connectionstrings_expanded = { for connection in var.connection_strings : connection.config_name => {
    name  = connection.config_name
    type  = connection.type
    value = "@Microsoft.KeyVault(SecretUri=https://${var.context.environment}-kv-${var.context.product}-${connection.domain}-${var.context.location_abbr}.azure.net/secrets/${connection.secret_name})"
  } }
  secure_settings_expanded = { for setting in var.secure_settings : setting.config_name => "@Microsoft.KeyVault(SecretUri=https://${var.context.environment}-kv-${var.context.product}-${setting.domain}-${var.context.location_abbr}.azure.net/secrets/${setting.secret_name})" }
  app_settings             = merge(local.default_app_settings, var.app_settings, local.secure_settings_expanded)
  extra_domain_kvs         = distinct(concat([for setting in var.secure_settings : setting.domain]))
  # Diagnostic Settings Config
  log_workspace = {
    name                = "${var.context.environment}-logs-${var.context.product}-workspace-${var.context.location_abbr}"
    resource_group_name = "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
  }
  linux_webapp_diagnostic_log_categories = ["AppServiceAuditLogs"]

  cf_token_secret_name   = "ext-cloudflare-dns-api-token"
  cf_zone_id_secret_name = "ext-cloudflare-zone-id"
}

data "azurerm_key_vault" "key_vault" {
  name                = "${var.context.environment}-kv-${var.context.product}-${var.domain}-${var.context.location_abbr}"
  resource_group_name = "${var.context.environment}-rg-${var.context.product}-${var.domain}-shared-${var.context.location_abbr}"
}

data "azurerm_key_vault" "extra_key_vaults" {
  for_each            = toset(local.extra_domain_kvs)
  name                = "${var.context.environment}-kv-${var.context.product}-${each.key}-${var.context.location_abbr}"
  resource_group_name = "${var.context.environment}-rg-${var.context.product}-${each.key}-shared-${var.context.location_abbr}"
}

data "azurerm_key_vault" "infra_key_vault" {
  name                = "${var.context.environment}-kv-${var.context.product}-infra-${var.context.location_abbr}"
  resource_group_name = "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
}

data "azurerm_key_vault_secret" "cf_zone_id" {
  name         = local.cf_zone_id_secret_name
  key_vault_id = data.azurerm_key_vault.infra_key_vault.id
}

data "azurerm_log_analytics_workspace" "law" {
  name                = local.log_workspace.name
  resource_group_name = local.log_workspace.resource_group_name
}

resource "azurerm_linux_web_app" "linux_webapp" {
  name                = local.webapp_name
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  service_plan_id     = var.app_service_plan_id
  tags                = local.tags

  site_config {
    always_on    = true
    worker_count = var.worker_count
    dynamic "cors" {
      for_each = var.cors_allowed_origins

      content {
        allowed_origins = var.cors_allowed_origins
      }
    }

    ip_restriction = [for r in var.access_rules : {
      action                    = r.action
      name                      = r.name
      priority                  = r.priority
      headers                   = []
      service_tag               = try(r.service_tag, null)
      ip_address                = try(r.ip_address, null)
      virtual_network_subnet_id = try(r.virtual_network_subnet_id, null)
    }]

  }

  app_settings = local.app_settings

  dynamic "logs" {
    for_each = var.enable_local_logging == true ? [1] : []
    content {
      application_logs {
        file_system_level = "Information"
      }
      http_logs {
        file_system {
          retention_in_mb   = 50
          retention_in_days = 3
        }

      }
    }
  }

  identity {
    type = local.identity_type
  }
  lifecycle {
    ignore_changes = [
      site_config[0].application_stack,
      app_settings,
      virtual_network_subnet_id
    ]
  }
}

resource "azurerm_linux_web_app_slot" "linux_webapp_slot" {
  name           = local.slot_name
  app_service_id = azurerm_linux_web_app.linux_webapp.id
  tags           = local.tags

  site_config {
    always_on    = true
    worker_count = var.worker_count

    dynamic "cors" {
      for_each = var.cors_allowed_origins

      content {
        allowed_origins = var.cors_allowed_origins
      }
    }

    health_check_path = var.health_check_path
    ip_restriction = [for r in var.access_rules : {
      action                    = r.action
      name                      = r.name
      priority                  = r.priority
      headers                   = []
      service_tag               = try(r.service_tag, null)
      ip_address                = try(r.ip_address, null)
      virtual_network_subnet_id = try(r.virtual_network_subnet_id, null)
    }]
  }

  dynamic "logs" {
    for_each = var.enable_local_logging == true ? [1] : []
    content {
      application_logs {
        file_system_level = "Information"
      }
      http_logs {
        file_system {
          retention_in_mb   = 50
          retention_in_days = 3
        }

      }
    }
  }
  app_settings = local.app_settings
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
      site_config[0].application_stack,
      virtual_network_subnet_id
    ]
  }
  depends_on = [
    azurerm_linux_web_app.linux_webapp
  ]
}

resource "azurerm_app_service_virtual_network_swift_connection" "regional_vnet_connection" {
  # count          = var.subnet_id == "" ? 0 : 1
  app_service_id = azurerm_linux_web_app.linux_webapp.id
  subnet_id      = var.subnet_id
  depends_on = [
    azurerm_linux_web_app.linux_webapp
  ]
}

resource "azurerm_app_service_slot_virtual_network_swift_connection" "regional_vnet_connection_staging_slot" {
  # count          = var.subnet_id == "" ? 0 : 1
  slot_name      = azurerm_linux_web_app_slot.linux_webapp_slot.name
  app_service_id = azurerm_linux_web_app.linux_webapp.id
  subnet_id      = var.subnet_id
  depends_on = [
    azurerm_linux_web_app_slot.linux_webapp_slot
  ]
}

resource "cloudflare_record" "cname_record" {
  count   = var.required_custom_dns == null ? 0 : 1
  zone_id = data.azurerm_key_vault_secret.cf_zone_id.value
  name    = var.required_custom_dns.sub_domain
  value   = azurerm_linux_web_app.linux_webapp.default_hostname
  type    = "CNAME"
  ttl     = 1
  proxied = true

  depends_on = [
    azurerm_linux_web_app.linux_webapp
  ]
}

resource "null_resource" "domain_verification_check" {
  count = var.required_custom_dns == null ? 0 : 1
  provisioner "local-exec" {
    command = "sleep 30"
  }
  triggers = {
    "before" = cloudflare_record.domain_verification[0].id
  }

  depends_on = [
    cloudflare_record.cname_record
  ]
}

resource "cloudflare_record" "domain_verification" {
  count   = var.required_custom_dns == null ? 0 : 1
  zone_id = data.azurerm_key_vault_secret.cf_zone_id.value
  name    = "asuid.${var.required_custom_dns.sub_domain}"
  value   = azurerm_linux_web_app.linux_webapp.custom_domain_verification_id
  type    = "TXT"
  ttl     = 1

  depends_on = [
    azurerm_linux_web_app.linux_webapp
  ]
}


resource "azurerm_app_service_custom_hostname_binding" "custom_binding" {
  count               = var.required_custom_dns == null ? 0 : 1
  hostname            = "${var.required_custom_dns.sub_domain}.${var.base_dns}"
  app_service_name    = azurerm_linux_web_app.linux_webapp.name
  resource_group_name = var.resource_group.name

  depends_on = [
    cloudflare_record.domain_verification,
    cloudflare_record.cname_record,
    null_resource.domain_verification_check
  ]
}

locals {
  all_key_vault_ids = merge({ for key, data in data.azurerm_key_vault.extra_key_vaults : "${key}" => data.id }, { "${var.domain}" = data.azurerm_key_vault.key_vault.id })
}

resource "azurerm_key_vault_access_policy" "app_access" {
  for_each     = local.all_key_vault_ids
  key_vault_id = each.value
  tenant_id    = azurerm_linux_web_app.linux_webapp.identity[0].tenant_id
  object_id    = azurerm_linux_web_app.linux_webapp.identity[0].principal_id
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
  tenant_id    = azurerm_linux_web_app_slot.linux_webapp_slot.identity[0].tenant_id
  object_id    = azurerm_linux_web_app_slot.linux_webapp_slot.identity[0].principal_id
  secret_permissions = [
    "Get", "List"
  ]
  lifecycle {
    ignore_changes = [
      key_vault_id
    ]
  }
}

#----------------------------------------------------------------------------------------------------------
# Web App Diagnostic Setting
#----------------------------------------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "linux_webapp_diag" {
  name                       = format("%s-diags", azurerm_linux_web_app.linux_webapp.name)
  target_resource_id         = azurerm_linux_web_app.linux_webapp.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.law.id

  dynamic "log" {
    for_each = local.linux_webapp_diagnostic_log_categories
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
    azurerm_linux_web_app.linux_webapp
  ]
  lifecycle {
    ignore_changes = [log]
  }
}

