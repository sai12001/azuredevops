locals {
  cf_token_secret_name   = "ext-cloudflare-bs-api-token"
  cf_zone_id_secret_name = "ext-cloudflare-bs-zone-id"

  office_ip_to_whitelist = [
    "115.112.125.113",
    "139.130.32.10"
  ]

  urls_to_whitelist = [
    "/api/bgingress/v1/heartbeat",
    "/api/bgingress/v1/processmessage"
  ]

  urls_to_blcok = [
    "/api/account/v1",
    "/api/racing/v1",
    "/api/sports/v1",
    "/api/bet/v1",
    "/api/bet/v1",
  ]

  transformed_allowed_ip_address = "(ip.src in { ${join(" ", local.office_ip_to_whitelist)} })"

  transformed_whitelisted_rule_list  = [for url in local.urls_to_whitelist : "(http.request.uri.path contains \"${url}\")"]
  transformed_whitelisted_expression = join(" or ", local.transformed_whitelisted_rule_list)

  transformed_block_rule_list  = [for url in local.urls_to_blcok : "(not ip.geoip.country in {\"AU\" \"NZ\"} and http.request.uri.path contains \"${url}\")"]
  transformed_block_expression = join(" or ", local.transformed_block_rule_list)


  rules = {
    "Allow_WhiteList_IPs" = {
      name       = "Allow Office IPs"
      action     = "allow"
      expression = local.transformed_allowed_ip_address
      priority   = 1
    }
    "Allow_WhiteList_Urls" = {
      name       = "Allow Whitelisted Urls"
      action     = "allow"
      expression = local.transformed_whitelisted_expression
      priority   = 2
    }
    "Block_Non_AUNZ" = {
      name       = "Block Non AU and NZ Access"
      action     = "block"
      expression = local.transformed_block_expression
      priority   = 10
    }
  }
}


data "azurerm_key_vault_secret" "cf_zone_id" {
  name         = local.cf_zone_id_secret_name
  key_vault_id = data.azurerm_key_vault.infra_key_vault.id
}

module "firewall_rule_geo_restriction" {
  source   = "../../../../DevOps/terraform/modules/cloudflare/firewall-rule"
  for_each = local.rules
  rule = {
    zone_id  = data.azurerm_key_vault_secret.cf_zone_id.value
    name     = each.value.name
    action   = each.value.action
    priority = each.value.priority
    filter = {
      expression = each.value.expression
    }
  }
}
