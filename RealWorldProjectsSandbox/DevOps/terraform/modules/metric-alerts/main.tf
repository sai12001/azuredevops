
locals {
  tags = merge(var.resource_group.tags, var.tags)
}
# resource "azurerm_monitor_metric_alert" "metric_alerts" {
#   for_each = var.metric_alert

#   name                = "${var.context.environment}-ma-${var.metric_alert_name}-${each.value.metric_name}"
#   resource_group_name = var.resource_group.name
#   scopes              = ["${var.resource_id}"]
#   description         = each.value.description

#   criteria {
#     metric_namespace = each.value.metric_namespace
#     metric_name      = each.value.metric_name
#     aggregation      = each.value.aggregation
#     operator         = each.value.operator
#     threshold        = each.value.threshold

#     dynamic "dimension" {
#       for_each = each.value.dimension_name == "No Dimensions" ? [] : [1]
#       content {
#         name     = each.value.dimension_name
#         operator = each.value.dimension_operator
#         values   = each.value.dimension_values
#       }
#     }
#   }

#   dynamic "action" {
#     for_each = var.enable_action_group == true ? [1] : []
#     content {
#       action_group_id = var.action_group_id
#     }
#   }

#   tags = local.tags
# }
