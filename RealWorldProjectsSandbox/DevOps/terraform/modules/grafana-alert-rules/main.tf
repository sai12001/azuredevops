locals {
  grafana_metric_alert = defaults(var.grafana_metric_alert, {
    aggregation   = "Count"
    no_data_state = "NoData"
    trigger_eval_type = "gt"
  })
}

resource "grafana_rule_group" "classic_metrics_alerts" {
  name             = var.rule_group_name 
  folder_uid       = var.folder_uid
  interval_seconds = 240
  org_id           = 1
  dynamic "rule" {
    for_each = local.grafana_metric_alert
    content {
      name           = rule.value.alert_name
      for            = rule.value.timefor
      condition      = "trigger"
      no_data_state  = rule.value.no_data_state
      exec_err_state = "Alerting"
      annotations = {
        "summary"     = "${rule.value.alert_summary} | Actual Value - {{ $values.trigger0.Value }}"
        "description" = rule.value.alert_description
      }
      labels = {
        "domain"        = rule.value.domain
        "team"          = rule.value.team
        "og_priority"   = rule.value.severity
        "resource_type" = rule.value.resource_type
        "alert_type"    = rule.value.alert_type
        "environment"   = var.environment
      }
      data {
        ref_id         = "A"
        datasource_uid = var.datasource_uid
        query_type     = "Azure Monitor"
        relative_time_range {
          from = 600
          to   = 0
        }
        model = jsonencode({
          refId         = "A"
          hide          = false
          queryType     = "Azure Monitor"
          intervalMs    = 1000
          maxDataPoints = 43200
          azureMonitor = {
            aggregation = rule.value.aggregation
            timeGrain   = "auto"
            allowedTimeGrainsMs = [
              60000,
              300000,
              900000,
              1800000,
              3600000,
              21600000,
              43200000,
              86400000
            ]
            resourceGroup    = rule.value.resourceGroup
            metricNamespace  = rule.value.metricNamespace
            resourceName     = rule.value.resourceName
            metricName       = rule.value.metricName
            dimensionFilters = rule.value.dimensionFilters
            customNamespace  = rule.value.metricNamespace
          }
          subscription = rule.value.subscription
        })
      }
      data {
        ref_id         = "trigger"
        query_type     = ""
        datasource_uid = "-100"
        relative_time_range {
          from = 600
          to   = 0
        }
        model = <<EOT
      {
          "refId": "trigger",
          "hide": false,
          "type": "classic_conditions",
          "intervalMs": 1000,
          "maxDataPoints":43200,
          "datasource": {
              "uid": "-100",
              "type": "__expr__"
          },
          "conditions": [
              {
                  "type": "query",
                  "evaluator": {
                      "params": [
                          ${rule.value.metric_threshold}
                      ],
                      "type": "${rule.value.trigger_eval_type}"
                  },
                  "operator": {
                      "type": "and"
                  },
                  "query": {
                      "params": [
                          "A"
                      ]
                  },
                  "reducer": {
                      "params": [],
                      "type": "avg"
                  }
              }
          ],
          "expression": "A"
      }
      EOT
      }
    }

  }
}

