locals {
  domain_name = var.domain
  redis_name  = "${var.context.environment}-rdis-${var.context.product}-${local.domain_name}-shared"
  tags        = merge(var.resource_group.tags, var.tags)
  # Diagnostic Settings Config
  log_workspace = {
    name                = "${var.context.environment}-logs-${var.context.product}-workspace-${var.context.location_abbr}"
    resource_group_name = "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
  }
  redis_diagnostic_log_categories =["ConnectedClientList"]
}

data "azurerm_key_vault" "key_vault" {
  name                = "${var.context.environment}-kv-${var.context.product}-${local.domain_name}-${var.context.location_abbr}"
  resource_group_name = "${var.context.environment}-rg-${var.context.product}-${local.domain_name}-shared-${var.context.location_abbr}"
}
data "azurerm_log_analytics_workspace" "law" {
  name                = local.log_workspace.name
  resource_group_name = local.log_workspace.resource_group_name
}

# NOTE: the Name used for Redis needs to be globally unique
resource "azurerm_redis_cache" "redis_cache" {
  name                = local.redis_name
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  capacity            = var.capacity
  family              = var.family
  sku_name            = var.sku_name
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"

  redis_configuration {}
  tags = local.tags
}

resource "azurerm_key_vault_secret" "secret_redis_cache_connection_string" {
  name         = "redis-cache-connection-string-${azurerm_redis_cache.redis_cache.name}"
  key_vault_id = data.azurerm_key_vault.key_vault.id
  value        = azurerm_redis_cache.redis_cache.primary_connection_string
}

#----------------------------------------------------------------------------------------------------------
#Redis Cache Diagnostic Setting
#----------------------------------------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "redis_diags" {
  name                           = format("%s-diags", azurerm_redis_cache.redis_cache.name)
  target_resource_id             = azurerm_redis_cache.redis_cache.id
  log_analytics_workspace_id     = data.azurerm_log_analytics_workspace.law.id
  dynamic "log" {
    for_each = local.redis_diagnostic_log_categories
     content {
       category = log.value
       retention_policy {
         days    = var.log_analytics_retention
         enabled = false
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
    azurerm_redis_cache.redis_cache
  ]
}


# Private Endpoint
data "azurerm_private_dns_zone" "redis" {
  name                = "privatelink.redis.cache.windows.net"
  resource_group_name = var.resource_group.name
}

data "azurerm_subnet" "subnet" {
  name                 = "subnet-privatelinks"
  resource_group_name  = var.context.environment == "dev" ? "${var.context.environment}-rg-${var.context.product}-shared-infra-${var.context.location_abbr}" : "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
  virtual_network_name = "${var.context.environment}-vnet-ng-shared-${var.context.location_abbr}"
}

resource "azurerm_private_endpoint" "private_endpoints" {
  name                = lower("link-${local.redis_name}")
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  subnet_id           = data.azurerm_subnet.subnet.id

  private_service_connection {
    private_connection_resource_id = azurerm_redis_cache.redis_cache.id
    name                           = lower(local.redis_name)
    subresource_names              = ["redisCache"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "private-dns"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.redis.id]
  }

  lifecycle {
    ignore_changes = [subnet_id]
  }
}
