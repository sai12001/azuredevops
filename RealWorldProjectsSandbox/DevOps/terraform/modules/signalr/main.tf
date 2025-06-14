locals {
  domain_name  = var.domain
  signalr_name = "${var.context.environment}-sigr-${var.context.product}-${var.domain}"
  tags         = merge(var.resource_group.tags, var.tags)
  # Diagnostic Settings Config
  log_workspace = {
    name                = "${var.context.environment}-logs-${var.context.product}-workspace-${var.context.location_abbr}"
    resource_group_name = "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
  } 
}

data "azurerm_log_analytics_workspace" "law" {
  name                = local.log_workspace.name
  resource_group_name = local.log_workspace.resource_group_name
}

resource "azurerm_signalr_service" "signalr_service" {
  name                = local.signalr_name
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  sku {
    name     = var.sku.name
    capacity = var.sku.capacity
  }

  cors {
    allowed_origins = var.allowed_origins
  }

  connectivity_logs_enabled = var.connectivity_logs_enabled
  messaging_logs_enabled    = var.messaging_logs_enabled
  live_trace_enabled        = var.live_trace_enabled
  service_mode              = var.service_mode


  # Creation of Upstream Endpoint when service mode is Serverless

  dynamic "upstream_endpoint" {
    for_each = var.service_mode == "Serverless" ? [1] : []
    content {

      category_pattern = var.category_pattern
      event_pattern    = var.event_pattern
      hub_pattern      = var.hub_pattern
      url_template     = var.url_template

    }
  }
  tags = local.tags
}

data "azurerm_key_vault" "key_vault" {
  name                = "${var.context.environment}-kv-${var.context.product}-${local.domain_name}-${var.context.location_abbr}"
  resource_group_name = "${var.context.environment}-rg-${var.context.product}-${local.domain_name}-shared-${var.context.location_abbr}"
}

resource "azurerm_key_vault_secret" "secret_signalr_connection_string" {
  name         = "sigr-connection-string-${azurerm_signalr_service.signalr_service.name}"
  key_vault_id = data.azurerm_key_vault.key_vault.id
  value        = azurerm_signalr_service.signalr_service.primary_connection_string

}
#----------------------------------------------------------------------------------------------------------
#SignalR Diagnostic Setting
#----------------------------------------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "signalr_diags" {
  name                           = format("%s-diags", azurerm_signalr_service.signalr_service.name)
  target_resource_id             = azurerm_signalr_service.signalr_service.id
  log_analytics_workspace_id     = data.azurerm_log_analytics_workspace.law.id
  log {
      category = "AllLogs"

      retention_policy {
        days    = var.log_analytics_retention
        enabled = false
      }
    }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }

  }
  depends_on = [
    azurerm_signalr_service.signalr_service
  ]
}


# Private Endpoint
data "azurerm_private_dns_zone" "signalr" {
  name                = "privatelink.service.signalr.net"
  resource_group_name = var.resource_group.name
}

data "azurerm_subnet" "subnet" {
  name                 = "subnet-privatelinks"
  resource_group_name  = var.context.environment == "dev" ? "${var.context.environment}-rg-${var.context.product}-shared-infra-${var.context.location_abbr}" : "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
  virtual_network_name = "${var.context.environment}-vnet-ng-shared-${var.context.location_abbr}"
}

resource "azurerm_private_endpoint" "private_endpoints" {
  name                = lower("link-${local.signalr_name}")
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  subnet_id           = data.azurerm_subnet.subnet.id

  private_service_connection {
    private_connection_resource_id = azurerm_signalr_service.signalr_service.id
    name                           = lower(local.signalr_name)
    subresource_names              = ["signalr"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "private-dns"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.signalr.id]
  }

  lifecycle {
    ignore_changes = [subnet_id]
  }
}

