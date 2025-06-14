locals {
  grafana-ai-log-based-alerts = var.grafana-ai-log-based-alerts
}

resource "grafana_rule_group" "log_based_alerts" {
  name             = var.rule_group_name 
  folder_uid       = var.folder_uid
  interval_seconds = var.interval_seconds
  org_id           = 1
  dynamic "rule" {
    for_each = toset(local.grafana-ai-log-based-alerts)
    content {
      name           = rule.value.alert_name
      for            = var.timefor
      condition      = "C"
      no_data_state  = rule.value.no_data_state
      exec_err_state = "Alerting"
      annotations = {
        "summary"     = "${rule.value.alert_summary}"
        "description" = rule.value.alert_description
      }
      labels = {
        "domain"        = var.domain
        "team"          = rule.value.team
        "og_priority"   = rule.value.severity
        "resource_type" = var.resource_type
        "alert_type"    = var.alert_type
        "environment"   = var.environment
      }
      data {
        ref_id         = "A"
        datasource_uid = var.datasource_uid
        query_type     = "Azure Log Analytics"
        relative_time_range {
          from = 600
          to   = 0
        }
        model = jsonencode({
          azureLogAnalytics: {
            query: rule.value.query,
            resource: "/subscriptions/${var.subscription}/resourceGroups/${var.resourceGroup}/providers/Microsoft.Insights/components/${var.resourceName}",
            resultFormat: "table"
          }
          azureMonitor: {
              allowedTimeGrainsMs: [],
              timeGrain: "auto"
          },
          hide: false,
          intervalMs: 1000,
          maxDataPoints: 43200,
          queryType: "Azure Log Analytics",
          refId: "A"
        })
      }
      data {
        ref_id     = "B"
        query_type = ""
        relative_time_range {
          from = 600
          to   = 0
        }
        datasource_uid = "-100"
        model = <<EOT
        {
          "conditions": [
            {
              "evaluator": {
                  "params": [],
                  "type": "gt"
              },
              "operator": {
                  "type": "and"
              },
              "query": {
                  "params": [
                      "B"
                  ]
              },
              "reducer": {
                  "params": [],
                  "type": "last"
              },
              "type": "query"
            }
          ],
          "datasource": {
            "type": "__expr__",
            "uid": "-100"
          },
          "expression": "A",
          "hide": false,
          "intervalMs": 1000,
          "maxDataPoints": 43200,
          "reducer": "last",
          "refId": "B",
          "type": "reduce"
        }
        EOT
      }
      data {
        ref_id = "C"
        query_type = ""
        relative_time_range  {
          from = 600
          to   = 0
        }
        datasource_uid = "-100"
        model = <<EOT
        {
          "conditions": [
            {
              "evaluator": {
                "params": [
                  0
                ],
                "type": "gt"
              },
              "operator": {
                  "type": "and"
              },
              "query": {
                  "params": [
                      "C"
                    ]
                  },
              "reducer": {
                "params": [],
                "type": "last"
              },
              "type": "query"
            }
          ],
          "datasource": {
              "type": "__expr__",
              "uid": "-100"
          },
          "expression": "B",
          "hide": false,
          "intervalMs": 1000,
          "maxDataPoints": 43200,
          "refId": "C",
          "type": "threshold"
        }
        EOT
      }
    }
  }
}
