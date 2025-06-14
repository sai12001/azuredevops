locals {
  tags                          = merge(var.resource_group.tags, var.tags)
  domain_name                   = var.domain
  apim_name                     = "${var.context.environment}-apim-${var.context.product}-${local.domain_name}-shared"
  publisher_name                = var.apim_configs.publisher_name
  publisher_email               = var.apim_configs.publisher_email
  sku_name                      = var.apim_configs.sku_name
  base_dns                      = var.apim_configs.base_dns
  host_name                     = var.context.environment == "prd" ? "api.${local.base_dns}" : "api-${var.context.environment}.${local.base_dns}"
  cf_token_secret_name          = "ext-cloudflare-dns-api-token"
  cf_zone_id_secret_name        = "ext-cloudflare-zone-id"
  apim_application_insight_name = "${var.context.environment}-ai-${var.context.product}-apim-shared"
  log_workspace = {
    name                = "${var.context.environment}-logs-${var.context.product}-workspace-${var.context.location_abbr}"
    resource_group_name = "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
  }
  apim_diagnostic_log_categories = ["GatewayLogs"]

}

data "azurerm_key_vault" "domain_key_vaults" {
  for_each            = toset(var.binded_domains)
  name                = "${var.context.environment}-kv-${var.context.product}-${each.key}-${var.context.location_abbr}"
  resource_group_name = "${var.context.environment}-rg-${var.context.product}-${each.key}-shared-${var.context.location_abbr}"
}

data "azurerm_key_vault" "infra_key_vault" {
  name                = "${var.context.environment}-kv-${var.context.product}-infra-${var.context.location_abbr}"
  resource_group_name = "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
}

data "azurerm_key_vault_secret" "cf_api_token" {
  name         = local.cf_token_secret_name
  key_vault_id = data.azurerm_key_vault.domain_key_vaults["infra"].id
}

data "azurerm_subnet" "apim_subnet" {
  name                 = "subnet-apim"
  virtual_network_name = var.vnet_config.name
  resource_group_name  = var.vnet_config.resource_group
}

data "azurerm_log_analytics_workspace" "law" {
  name                = local.log_workspace.name
  resource_group_name = local.log_workspace.resource_group_name
}

data "azurerm_key_vault_secret" "grafana_datasource_id" {
  name         = "ext-grafana-data-source-id"
  key_vault_id = data.azurerm_key_vault.infra_key_vault.id
}

data "azurerm_redis_cache" "redis_cache" {
  name                = var.redis_cache_name
  resource_group_name = var.resource_group.name
}

resource "tls_private_key" "private_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  email_address   = local.publisher_email
}

resource "acme_certificate" "certificate" {
  account_key_pem           = acme_registration.reg.account_key_pem
  common_name               = var.context.environment == "prd" ? "*.${local.base_dns}" : "*.${local.base_dns}"
  subject_alternative_names = []

  dns_challenge {
    provider = "cloudflare"
    config = {
      CLOUDFLARE_DNS_API_TOKEN = data.azurerm_key_vault_secret.cf_api_token.value
    }
  }
}

resource "azurerm_key_vault_certificate" "secret_certificate" {
  name         = lower(replace(local.host_name, ".", "-"))
  key_vault_id = data.azurerm_key_vault.domain_key_vaults["infra"].id

  certificate {
    contents = acme_certificate.certificate.certificate_p12
    password = ""
  }
}

resource "azurerm_api_management" "apim" {
  count               = local.domain_name == "infra" ? 1 : 0
  name                = local.apim_name
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  publisher_name      = local.publisher_name
  publisher_email     = local.publisher_email
  sku_name            = local.sku_name
  identity {
    type = "SystemAssigned"
  }
  virtual_network_type = "External"

  virtual_network_configuration {
    subnet_id = data.azurerm_subnet.apim_subnet.id
  }

  timeouts {
    create = "60m"
    update = "60m"
  }
  lifecycle {
    prevent_destroy = true
  }

  dynamic "certificate" {
    for_each = var.certificates #{for cert in var.certificates:  cert.encoded_certificate => cert}
    content {
      encoded_certificate = filebase64(certificate.value.encoded_certificate)
      store_name          = certificate.value.store_name
    }
  }

}

resource "azurerm_api_management_redis_cache" "integrate_apim_rediscache" {
  name              = data.azurerm_redis_cache.redis_cache.name
  api_management_id = azurerm_api_management.apim[0].id
  connection_string = data.azurerm_redis_cache.redis_cache.primary_connection_string
  redis_cache_id    = data.azurerm_redis_cache.redis_cache.id
}

resource "azurerm_api_management_custom_domain" "custom_domain" {
  count             = local.domain_name == "infra" ? 1 : 0
  api_management_id = azurerm_api_management.apim[0].id
  gateway {
    default_ssl_binding          = true
    host_name                    = local.host_name
    key_vault_id                 = azurerm_key_vault_certificate.secret_certificate.versionless_secret_id
    negotiate_client_certificate = true
  }
  depends_on = [
    azurerm_api_management.apim
  ]
}

data "azurerm_key_vault_secret" "cf_zone_id" {
  name         = local.cf_zone_id_secret_name
  key_vault_id = data.azurerm_key_vault.domain_key_vaults["infra"].id
}

resource "cloudflare_record" "dns_record" {
  zone_id = data.azurerm_key_vault_secret.cf_zone_id.value
  name    = var.context.environment == "prd" ? "api" : "api-${var.context.environment}"
  value   = trimprefix(azurerm_api_management.apim[0].gateway_url, "https://")
  proxied = true
  type    = "CNAME"
  ttl     = 1 # AUTO
  depends_on = [
    azurerm_api_management.apim
  ]
  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_api_management_product" "products" {
  for_each              = var.product_policies
  product_id            = each.key
  api_management_name   = azurerm_api_management.apim[0].name
  resource_group_name   = var.resource_group.name
  display_name          = each.key
  subscription_required = false
  approval_required     = false
  published             = true
  depends_on = [
    azurerm_api_management.apim
  ]
  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_api_management_product_policy" "product_policy" {
  for_each            = var.product_policies
  product_id          = azurerm_api_management_product.products[each.key].product_id
  api_management_name = azurerm_api_management.apim[0].name
  resource_group_name = var.resource_group.name
  xml_content         = each.value
  depends_on = [
    azurerm_api_management.apim
  ]
  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_key_vault_access_policy" "apim_access" {
  for_each     = toset(var.binded_domains)
  key_vault_id = data.azurerm_key_vault.domain_key_vaults[each.key].id
  tenant_id    = azurerm_api_management.apim[0].identity[0].tenant_id
  object_id    = azurerm_api_management.apim[0].identity[0].principal_id
  secret_permissions = [
    "Get", "List"
  ]
  lifecycle {
    ignore_changes = [
      key_vault_id
    ]
  }
  depends_on = [
    azurerm_api_management.apim
  ]
}

data "azurerm_key_vault_secret" "ext_auth0_keys" {
  for_each     = toset(["auth0-signing-key", "auth0-claimsnamespace", "auth0-authdomain"])
  name         = each.key
  key_vault_id = data.azurerm_key_vault.domain_key_vaults["account"].id
}

module "apim_named_value" {
  source         = "../named-value"
  resource_group = var.resource_group
  context        = var.context
  domain         = var.domain
  named_values = {
    "auth0-signing-key" = {
      is_secret = true
      secret_id = data.azurerm_key_vault_secret.ext_auth0_keys["auth0-signing-key"].versionless_id
    },
    "auth0-claimsnamespace" = {
      is_secret = true
      secret_id = data.azurerm_key_vault_secret.ext_auth0_keys["auth0-claimsnamespace"].versionless_id
    },
    "auth0-authdomain" = {
      is_secret = true
      secret_id = data.azurerm_key_vault_secret.ext_auth0_keys["auth0-authdomain"].versionless_id
    },
  }
  depends_on = [
    azurerm_api_management.apim
  ]
}


module "application_insights" {
  source                    = "../../application-insights"
  application_insights_name = local.apim_application_insight_name
  resource_group            = var.resource_group
  log_workspace             = local.log_workspace
  application_type          = "other"
  tags                      = local.tags
  domain                    = "infra"
  team                      = "cloudops"
  # datasource_id             = data.azurerm_key_vault_secret.grafana_datasource_id.value
  # Dashboard_Name            = "infra | App Insight Dashboard"
  # alert_short_name          = "apim"
  environment = var.context.environment
  depends_on = [
    azurerm_api_management.apim
  ]
}

module "grafana_app_insights" {
  source            = "../../application-insights/grafana"
  context           = var.context
  resource_group    = var.resource_group
  team              = "cloudops"
  domain            = "infra"
  app_insights_name = local.apim_application_insight_name
  datasource_id     = data.azurerm_key_vault_secret.grafana_datasource_id.value
}


resource "azurerm_api_management_logger" "ai_logger" {
  name                = "apim"
  api_management_name = azurerm_api_management.apim[0].name
  resource_group_name = var.resource_group.name
  resource_id         = module.application_insights.application_insights.id

  application_insights {
    instrumentation_key = module.application_insights.application_insights.instrumentation_key
  }
  depends_on = [
    azurerm_api_management.apim
  ]
}

#----------------------------------------------------------------------------------------------------------
# APIM Diagnostic Setting
#----------------------------------------------------------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "apim_diags" {
  count                      = local.domain_name == "infra" ? 1 : 0
  name                       = format("%s-diags", azurerm_api_management.apim[0].name)
  target_resource_id         = azurerm_api_management.apim[0].id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.law.id
  dynamic "log" {
    for_each = local.apim_diagnostic_log_categories
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
  lifecycle {
    ignore_changes = [log, log_analytics_workspace_id]
  }
  depends_on = [
    azurerm_api_management.apim
  ]
}

