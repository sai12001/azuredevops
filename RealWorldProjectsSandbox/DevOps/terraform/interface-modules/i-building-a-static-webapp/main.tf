locals {
  team                = var.with_solution_configs.team_name
  domain_name         = var.with_solution_configs.domain_name
  solution_name       = var.with_solution_configs.solution_name
  resource_group_name = "${var.context.environment}-rg-${var.context.product}-${local.solution_name}-${var.context.location_abbr}"

  # Data Storage Accounts ===========================================
  static_website = defaults(var.needs_static_website, {
    account_tier             = "Standard"
    account_replication_type = "GRS"
    account_kind             = "StorageV2"
  })

  # Tags ============================================================
  tags = {
    solution_name = local.solution_name
    domain        = local.domain_name
  }

  #TODO to implement mapping to allow any subdomain 
  base_domains = ["blackstream.com.au", "surge.com.au", "amusedgroup.com"]

  #TODO hard coded surege zone id, it should use api token and zone-id depends on subdomain
  surge_cf_token_secret_name   = "ext-cloudflare-surge-dns-api-token"
  surge_cf_zone_id_secret_name = "ext-cloudflare-surge-zone-id"
}

#########################################
#          Source
#########################################
data "azurerm_key_vault" "infra_key_vault" {
  name                = "${var.context.environment}-kv-${var.context.product}-infra-${var.context.location_abbr}"
  resource_group_name = "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
}

data "azurerm_key_vault_secret" "cf_zone_id" {
  name         = local.surge_cf_zone_id_secret_name
  key_vault_id = data.azurerm_key_vault.infra_key_vault.id
}

module "rg_solution" {
  source              = "../../modules/resource-group"
  context             = var.context
  belong_to_team      = local.team
  resource_group_name = local.resource_group_name
  tags                = local.tags
}

resource "cloudflare_record" "cname_record" {
  for_each = { for stawebsite in var.needs_static_website : stawebsite.name => stawebsite if stawebsite.sub_domain_name != null }
  zone_id  = data.azurerm_key_vault_secret.cf_zone_id.value
  name     = each.value.sub_domain_name
  value    = azurerm_storage_account.static_web_site[each.key].primary_web_host
  type     = "CNAME"
  ttl      = 1
  proxied  = true
}

resource "cloudflare_record" "asverify_cname_record" {
  for_each = { for stawebsite in var.needs_static_website : stawebsite.name => stawebsite if stawebsite.sub_domain_name != null }
  zone_id  = data.azurerm_key_vault_secret.cf_zone_id.value
  name     = "asverify.${each.value.sub_domain_name}"
  value    = "asverify.${azurerm_storage_account.static_web_site[each.key].primary_web_host}"
  type     = "CNAME"
  ttl      = 1
  proxied  = false
}

resource "null_resource" "domain_verification_check" {
  for_each = { for stawebsite in var.needs_static_website : stawebsite.name => stawebsite if stawebsite.sub_domain_name != null }
  provisioner "local-exec" {
    command     = "start-sleep 60"
    interpreter = ["powerShell", "-Command"]
  }
  triggers = {
    always_run = "${timestamp()}"
  }

  depends_on = [
    cloudflare_record.cname_record,
    cloudflare_record.asverify_cname_record
  ]
}

resource "null_resource" "add_custom_domain_storage_account" {
  for_each = { for stawebsite in var.needs_static_website : stawebsite.name => stawebsite if stawebsite.sub_domain_name != null }
  provisioner "local-exec" {
    command     = <<EOT
        
        $storageAccountName = '${azurerm_storage_account.static_web_site[each.key].name}'
        
        az storage account update `
        --name $storageAccountName `
        --resource-group '${local.resource_group_name}' `
        --custom-domain '${each.value.sub_domain_name}.${each.value.base_domain}' `
        --use-subdomain $true
    EOT
    interpreter = ["powerShell", "-Command"]
  }
  triggers = {
    always_run = "${timestamp()}"
  }

  depends_on = [
    null_resource.domain_verification_check
  ]
}

resource "azurerm_storage_account" "static_web_site" {
  for_each                  = { for stawebsite in local.static_website : stawebsite.name => stawebsite }
  name                      = lower(substr(replace("${var.context.environment}stawebapp${var.context.product}${each.value.name}", "-", ""), 0, 24))
  resource_group_name       = local.resource_group_name
  location                  = var.context.location
  account_kind              = each.value.account_kind
  account_tier              = each.value.account_tier
  account_replication_type  = each.value.account_replication_type
  enable_https_traffic_only = false
  is_hns_enabled            = false
  tags                      = local.tags
  static_website {
    index_document = "index.html"
  }

  depends_on = [
    module.rg_solution
  ]
}



