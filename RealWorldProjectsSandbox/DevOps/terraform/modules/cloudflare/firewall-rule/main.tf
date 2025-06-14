locals {
  rule = defaults(var.rule, {
    filter = {
      description = "Rule filter"
    }
  })
}


resource "cloudflare_filter" "rule_filter" {
  zone_id     = var.rule.zone_id
  description = var.rule.filter.description
  expression  = var.rule.filter.expression
}

resource "cloudflare_firewall_rule" "rule" {
  zone_id     = var.rule.zone_id
  description = var.rule.name
  filter_id   = cloudflare_filter.rule_filter.id
  action      = var.rule.action
  priority    = var.rule.priority
}
