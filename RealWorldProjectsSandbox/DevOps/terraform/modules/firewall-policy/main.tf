#Azure Firewall Policy Deployment
#Firewall Policy
resource "azurerm_firewall_policy" "fw_policy" {
  name                = lower("fw-policy-collection-${var.firewall_name}")
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
}
resource "azurerm_firewall_policy_rule_collection_group" "fw_policy_collection" {
  name               = lower("fw-policy-rule-collection-${var.firewall_name}")
  firewall_policy_id = azurerm_firewall_policy.fw_policy.id
  priority           = 500
  #Placeholder for Firewall Application Rules
  # application_rule_collection {
  #   name               = lower("fw-app-rule-collection-${var.firewall_name}")
  #   priority           = var.firewall_application_rules.collection_priority
  #   action             = var.firewall_application_rules.action
  #   dynamic "rule" { 
  #     for_each = var.firewall_application_rules.rule
  #     content {
  #         name              = rule.value.name
  #         source_addresses  = rule.value.source_addresses
  #         destination_fqdns = rule.value.destination_fqdns
  #         dynamic "protocols" {
  #           for_each = var.firewall_application_rules.protocols
  #           content{
  #           type = protocols.value.type
  #           port = protocols.value.port
  #         }
  #       }
  #     }
  #   }
  #  }

  network_rule_collection {
    name                  = lower("fw-network-rule-collection-${var.firewall_name}")
    priority              = var.firewall_network_rules.collection_priority
    action                = var.firewall_network_rules.action
    dynamic "rule" {
      for_each = var.firewall_network_rules.rule
      content{
          name                  = rule.value.name
          source_addresses      = rule.value.source_addresses
          destination_ports     = rule.value.destination_ports
          destination_addresses = rule.value.destination_addresses
          protocols             = rule.value.protocols
      }
    }
  }

  nat_rule_collection {
    name                  = lower("fw-nat-rule-collection-${var.firewall_name}")
    priority              = var.firewall_nat_rules.collection_priority
    action                = var.firewall_nat_rules.action
    dynamic "rule" {
      for_each = var.firewall_nat_rules.rule
      content{
      name                  = rule.value.name
      source_addresses      = rule.value.source_addresses
      destination_ports     = rule.value.destination_ports
      destination_address   = var.firewall_public_ip[0]
      protocols             = rule.value.protocols
      translated_address    = rule.value.translated_address
      translated_port       = rule.value.translated_port
    }
    }
  }
}