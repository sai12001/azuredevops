locals {
  tags                               = merge(var.resource_group.tags, var.tags)
  domain_name                        = var.domain
  servicebus_namespace_name          = "${var.context.environment}-sb-${var.context.product}-infra-shared-${var.context.location_abbr}"
  servicebus_namespace_resourcegroup = "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
  service_bus_namespace_config = defaults(var.servicebus_namespace, {
    sku            = "Standard"
    capacity       = 0
    zone_redundant = false
  })

  servicebus_queues = defaults(var.servicebus_queues, {
    enable_partitioning                     = false
    requires_session                        = false
    requires_duplicate_detection            = false
    duplicate_detection_history_time_window = "PT10M"
    default_message_ttl                     = "P14D"
    max_delivery_count                      = 10
    auth_rules = {
      listen = true
      send   = false
      manage = false
    }
  })

  servicebus_topics = defaults(var.servicebus_topics, {
    enable_partitioning = false
    auth_rules = {
      listen = true
      send   = false
      manage = false
    }
  })


  addon_queue_auth_rules = defaults(var.servicebus_queue_auth_rules, {
    listen = true
    send   = false
    manage = false
  })

  domain_queue_auth_rules = flatten([for q in local.servicebus_queues : [
    for auth in q.auth_rules : {
      domain_name = q.domain_name
      queue_name  = q.name
      name        = auth.name
      listen      = auth.listen
      send        = auth.send
      manage      = auth.manage
    }
  ]])
  queue_auth_rules = { for rule in distinct(concat(local.addon_queue_auth_rules, local.domain_queue_auth_rules)) : "${rule.domain_name}-${rule.queue_name}-${rule.name}" => rule }

  addon_topic_auth_rules = defaults(var.servicebus_topic_auth_rules, {
    listen = true
    send   = false
    manage = false
  })

  domain_topic_auth_rules = flatten([for t in local.servicebus_topics : [
    for auth in t.auth_rules : {
      domain_name = t.domain_name
      topic_name  = t.name
      name        = auth.name
      listen      = auth.listen
      send        = auth.send
      manage      = auth.manage
    }
  ]])

  topic_auth_rules = { for rule in distinct(concat(local.addon_topic_auth_rules, local.domain_topic_auth_rules)) : "${rule.domain_name}-${rule.topic_name}-${rule.name}" => rule }

  servicebus_topic_subscriptions = defaults(var.servicebus_topic_subscriptions, {
    max_delivery_count                      = 10
    forward_to_queue                        = ""
    forward_dead_lettered_messages_to_queue = ""
    enable_batched_operations               = false
    requires_session                        = false
  })
  topic_subscriptions                   = { for sub in local.servicebus_topic_subscriptions : "${sub.domain_name}-${sub.topic_name}-${sub.name}" => sub }
  topic_subscriptions_sql_rules         = { for sub in local.servicebus_topic_subscriptions : "${sub.domain_name}-${sub.topic_name}-${sub.name}" => sub if sub.sql_filter != null }
  topic_subscriptions_correlation_rules = { for sub in local.servicebus_topic_subscriptions : "${sub.domain_name}-${sub.topic_name}-${sub.name}" => sub if sub.correlation_filter != null }
  # Diagnostic Settings Config
  log_workspace = {
    name                = "${var.context.environment}-logs-${var.context.product}-workspace-${var.context.location_abbr}"
    resource_group_name = "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
  }
  servicebus_diagnostic_log_categories = ["OperationalLogs", "VNetAndIPFilteringLogs"]

}

data "azurerm_log_analytics_workspace" "law" {
  name                = local.log_workspace.name
  resource_group_name = local.log_workspace.resource_group_name
}

data "azurerm_servicebus_namespace" "data_sb_namespace" {
  name                = local.servicebus_namespace_name
  resource_group_name = local.servicebus_namespace_resourcegroup
  depends_on = [
    azurerm_servicebus_namespace.sb_namespace
  ]
}

data "azurerm_key_vault" "key_vault" {
  name                = "${var.context.environment}-kv-${var.context.product}-${local.domain_name}-${var.context.location_abbr}"
  resource_group_name = "${var.context.environment}-rg-${var.context.product}-${local.domain_name}-shared-${var.context.location_abbr}"
}

data "azurerm_servicebus_topic" "data_sb_topics" {
  for_each            = local.topic_auth_rules
  name                = "${each.value.domain_name}-${each.value.topic_name}"
  resource_group_name = local.servicebus_namespace_resourcegroup
  namespace_name      = local.servicebus_namespace_name
  depends_on = [
    azurerm_servicebus_topic.sb_topics
  ]
}

data "azurerm_servicebus_queue" "data_sb_queues" {
  for_each            = local.queue_auth_rules
  name                = "${each.value.domain_name}-${each.value.queue_name}"
  resource_group_name = local.servicebus_namespace_resourcegroup
  namespace_name      = local.servicebus_namespace_name
  depends_on = [
    azurerm_servicebus_queue.sb_queues
  ]
}

data "azurerm_servicebus_topic" "data_sb_topics_for_subs" {
  for_each            = local.topic_subscriptions
  name                = "${each.value.domain_name}-${each.value.topic_name}"
  resource_group_name = local.servicebus_namespace_resourcegroup
  namespace_name      = local.servicebus_namespace_name
  depends_on = [
    azurerm_servicebus_topic.sb_topics
  ]
}


resource "azurerm_servicebus_namespace" "sb_namespace" {
  count               = var.servicebus_namespace == null ? 0 : 1
  name                = local.servicebus_namespace_name
  location            = var.resource_group.location
  resource_group_name = local.servicebus_namespace_resourcegroup
  sku                 = local.service_bus_namespace_config.sku
  capacity            = local.service_bus_namespace_config.capacity
  zone_redundant      = local.service_bus_namespace_config.zone_redundant
  tags                = local.tags
}

resource "azurerm_servicebus_queue" "sb_queues" {
  for_each                                = { for queue in local.servicebus_queues : "${queue.domain_name}-${queue.name}" => queue }
  name                                    = "${each.value.domain_name}-${each.value.name}"
  namespace_id                            = data.azurerm_servicebus_namespace.data_sb_namespace.id
  enable_partitioning                     = each.value.enable_partitioning
  max_delivery_count                      = each.value.max_delivery_count
  requires_session                        = each.value.requires_session
  requires_duplicate_detection            = each.value.requires_duplicate_detection
  duplicate_detection_history_time_window = each.value.duplicate_detection_history_time_window
  default_message_ttl                     = each.value.default_message_ttl
}

resource "azurerm_servicebus_queue_authorization_rule" "servicebus_queue_auth_rules" {
  for_each = local.queue_auth_rules
  name     = "${each.value.domain_name}-${each.value.name}"
  queue_id = data.azurerm_servicebus_queue.data_sb_queues[each.key].id
  listen   = each.value.listen
  send     = each.value.send
  manage   = each.value.manage
}

resource "azurerm_key_vault_secret" "secrets_queue_connectionstrings" {
  for_each     = azurerm_servicebus_queue_authorization_rule.servicebus_queue_auth_rules
  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = "queue-connection-string-${each.key}"
  value        = each.value.primary_connection_string
  lifecycle {
    ignore_changes = [
      key_vault_id
    ]
  }
  depends_on = [
    azurerm_servicebus_queue_authorization_rule.servicebus_queue_auth_rules
  ]
}

resource "azurerm_servicebus_topic" "sb_topics" {
  for_each            = { for topic in local.servicebus_topics : "${topic.domain_name}-${topic.name}" => topic }
  name                = "${each.value.domain_name}-${each.value.name}"
  namespace_id        = data.azurerm_servicebus_namespace.data_sb_namespace.id
  enable_partitioning = each.value.enable_partitioning
}

resource "azurerm_servicebus_topic_authorization_rule" "sb_topics_auth_rules" {
  for_each = local.topic_auth_rules
  name     = "${each.value.domain_name}-${each.value.name}"
  topic_id = data.azurerm_servicebus_topic.data_sb_topics[each.key].id
  listen   = each.value.listen
  send     = each.value.send
  manage   = each.value.manage
}

resource "azurerm_key_vault_secret" "secrets_topic_connectionstrings" {
  for_each     = azurerm_servicebus_topic_authorization_rule.sb_topics_auth_rules
  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = "topic-connection-string-${each.key}"
  value        = each.value.primary_connection_string
  lifecycle {
    ignore_changes = [
      key_vault_id
    ]
  }
  depends_on = [
    azurerm_servicebus_topic_authorization_rule.sb_topics_auth_rules
  ]
}

resource "azurerm_servicebus_subscription" "sb_topic_subscriptions" {
  for_each                          = local.topic_subscriptions
  topic_id                          = data.azurerm_servicebus_topic.data_sb_topics_for_subs[each.key].id
  name                              = each.value.name
  max_delivery_count                = each.value.max_delivery_count
  enable_batched_operations         = each.value.enable_batched_operations
  requires_session                  = each.value.requires_session
  forward_to                        = each.value.forward_to_queue
  forward_dead_lettered_messages_to = each.value.forward_dead_lettered_messages_to_queue
  depends_on = [
    azurerm_servicebus_topic.sb_topics
  ]
}

resource "azurerm_servicebus_subscription_rule" "sb_topic_subscription_sql_rules" {
  for_each        = local.topic_subscriptions_sql_rules
  name            = each.value.sql_filter.name
  subscription_id = azurerm_servicebus_subscription.sb_topic_subscriptions[each.key].id
  filter_type     = "SqlFilter"
  sql_filter      = each.value.sql_filter.filter_string
}

resource "azurerm_servicebus_subscription_rule" "sb_topic_subscription_corr_rules" {
  for_each        = local.topic_subscriptions_correlation_rules
  name            = each.value.correlation_filter.name
  subscription_id = azurerm_servicebus_subscription.sb_topic_subscriptions[each.key].id
  filter_type     = "CorrelationFilter"
  correlation_filter {
    # correlation_id      = each.value.correlation_filter.correlation_id
    # label               = each.value.correlation_filter.label
    # message_id          = each.value.correlation_filter.message_id
    # reply_to            = each.value.correlation_filter.reply_to
    # reply_to_session_id = each.value.correlation_filter.reply_to_session_id
    # session_id          = each.value.correlation_filter.session_id
    # to                  = each.value.correlation_filter.to
    properties          = each.value.correlation_filter.properties
  }
}

resource "azurerm_servicebus_namespace_authorization_rule" "namespace_rules" {
  for_each     = toset(var.servicebus_namespace_auth_rules)
  name         = "${local.domain_name}-${each.key}"
  namespace_id = data.azurerm_servicebus_namespace.data_sb_namespace.id
  listen       = true
  send         = true
  manage       = false
}

resource "azurerm_key_vault_secret" "secrets_namespace_connectionstrings" {
  for_each     = azurerm_servicebus_namespace_authorization_rule.namespace_rules
  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = "sbns-connection-string-${local.domain_name}-${each.key}"
  value        = each.value.primary_connection_string
  lifecycle {
    ignore_changes = [
      key_vault_id
    ]
  }
  depends_on = [
    azurerm_servicebus_topic_authorization_rule.sb_topics_auth_rules
  ]
}

#----------------------------------------------------------------------------------------------------------
# Service-Bus Diagnostic Setting
#----------------------------------------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "sb_namespace_diags" {
  count                      = var.servicebus_namespace == null ? 0 : 1
  name                       = format("%s-diags", azurerm_servicebus_namespace.sb_namespace[0].name)
  target_resource_id         = azurerm_servicebus_namespace.sb_namespace[0].id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.law.id
  #Placeholder to choose log categories
  dynamic "log" {
    for_each = local.servicebus_diagnostic_log_categories
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
  lifecycle {
    ignore_changes = [log]
  }
  depends_on = [
    azurerm_servicebus_namespace.sb_namespace
  ]
}
