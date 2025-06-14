locals {
  tags                   = merge(var.resource_group.tags, var.tags)
  domain_name            = var.domain
  apim_name              = "${var.context.environment}-apim-${var.context.product}-infra-shared"
  infra_rg_name          = "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
  plaintext_named_values = { for k, v in var.named_values : k => v if !v.is_secret }
  secret_named_values    = { for k, v in var.named_values : k => v if v.is_secret }
}

resource "azurerm_api_management_named_value" "named_value_plaintext" {
  for_each            = local.plaintext_named_values
  resource_group_name = local.infra_rg_name
  api_management_name = local.apim_name
  name                = each.key
  display_name        = each.key
  secret              = false
  value               = each.value.plain_text_value
}

resource "azurerm_api_management_named_value" "named_value_secrets" {
  for_each            = local.secret_named_values
  name                = each.key
  resource_group_name = local.infra_rg_name
  api_management_name = local.apim_name
  display_name        = each.key
  secret              = true
  value_from_key_vault {
    secret_id = each.value.secret_id
  }
}
