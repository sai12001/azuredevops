locals {
  folders = ["amused-infra", "amused-sre", "amused-account", "amused-bet", "amused-racing", "amused-promotion", "amused-console", "amused-summary", "amused-components", "amused-whatever", "amused-core", "amused-sport"]
  teams_connectors = {
    sre       = "https://amusedgrouphq.webhook.office.com/webhookb2/f46c6316-5e29-41ef-afd1-ee9842b82827@a1b670af-5de0-4614-989d-4fb1c24c42cf/IncomingWebhook/46d52c7c8cc44e299f16088e0b5f15b9/d6082d77-40fb-491a-89fe-79ab12dd306e"
    infra     = "https://amusedgrouphq.webhook.office.com/webhookb2/f46c6316-5e29-41ef-afd1-ee9842b82827@a1b670af-5de0-4614-989d-4fb1c24c42cf/IncomingWebhook/46d52c7c8cc44e299f16088e0b5f15b9/d6082d77-40fb-491a-89fe-79ab12dd306e"
    account   = "https://amusedgrouphq.webhook.office.com/webhookb2/f46c6316-5e29-41ef-afd1-ee9842b82827@a1b670af-5de0-4614-989d-4fb1c24c42cf/IncomingWebhook/1e3d4da8a6244ea39b0e123218b3e070/d6082d77-40fb-491a-89fe-79ab12dd306e"
    bet       = "https://amusedgrouphq.webhook.office.com/webhookb2/f46c6316-5e29-41ef-afd1-ee9842b82827@a1b670af-5de0-4614-989d-4fb1c24c42cf/IncomingWebhook/795088bb05394e36bd0330b81c029f9c/d6082d77-40fb-491a-89fe-79ab12dd306e"
    racing    = "https://amusedgrouphq.webhook.office.com/webhookb2/f46c6316-5e29-41ef-afd1-ee9842b82827@a1b670af-5de0-4614-989d-4fb1c24c42cf/IncomingWebhook/86736b4c34074bec832e407be54b273f/d6082d77-40fb-491a-89fe-79ab12dd306e"
    promotion = "https://amusedgrouphq.webhook.office.com/webhookb2/f46c6316-5e29-41ef-afd1-ee9842b82827@a1b670af-5de0-4614-989d-4fb1c24c42cf/IncomingWebhook/46d52c7c8cc44e299f16088e0b5f15b9/d6082d77-40fb-491a-89fe-79ab12dd306e"
    sport     = "https://amusedgrouphq.webhook.office.com/webhookb2/f46c6316-5e29-41ef-afd1-ee9842b82827@a1b670af-5de0-4614-989d-4fb1c24c42cf/IncomingWebhook/46d52c7c8cc44e299f16088e0b5f15b9/d6082d77-40fb-491a-89fe-79ab12dd306e"
    console   = "https://amusedgrouphq.webhook.office.com/webhookb2/f46c6316-5e29-41ef-afd1-ee9842b82827@a1b670af-5de0-4614-989d-4fb1c24c42cf/IncomingWebhook/46d52c7c8cc44e299f16088e0b5f15b9/d6082d77-40fb-491a-89fe-79ab12dd306e"
  }
  teams_connectors_envs = {
    dev = "https://amusedgrouphq.webhook.office.com/webhookb2/f46c6316-5e29-41ef-afd1-ee9842b82827@a1b670af-5de0-4614-989d-4fb1c24c42cf/IncomingWebhook/55072d946c8546d0acee2aa2f7216250/d6082d77-40fb-491a-89fe-79ab12dd306e"
    stg = "https://amusedgrouphq.webhook.office.com/webhookb2/f46c6316-5e29-41ef-afd1-ee9842b82827@a1b670af-5de0-4614-989d-4fb1c24c42cf/IncomingWebhook/0ea53b43d2864660a3058ec8b09cf715/d6082d77-40fb-491a-89fe-79ab12dd306e"
    prd = "https://amusedgrouphq.webhook.office.com/webhookb2/f46c6316-5e29-41ef-afd1-ee9842b82827@a1b670af-5de0-4614-989d-4fb1c24c42cf/IncomingWebhook/94db93956391495d893ad2268e38bac7/d6082d77-40fb-491a-89fe-79ab12dd306e"
  }
  iis_url = var.environment == "prd" ? "iis.internal.blackstream.com.au" : "iis.internal.${var.environment}.blackstream.com.au"
}

###############################################################
# Data Sources
###############################################################
data "azurerm_subscription" "current" {
}

data "azurerm_key_vault_secret" "grafana_datasource_id" {
  name         = "ext-grafana-data-source-id"
  key_vault_id = data.azurerm_key_vault.infra_key_vault.id
}

data "grafana_cloud_stack" "cloud_stack" {
  provider = grafana.root
  slug     = "${var.environment}nextgen"
}

data "grafana_synthetic_monitoring_probes" "main" {
}

###############################################################
# Grafana Infra
###############################################################

# Creating an API key in Grafana instance to be used for creating resources in Grafana instance
resource "grafana_api_key" "api_key" {
  provider = grafana.root

  cloud_stack_slug = data.grafana_cloud_stack.cloud_stack.slug
  name             = "${var.environment}nextgen-apikey"
  role             = "Admin"
}

resource "azurerm_key_vault_secret" "kv_secret_grafana_apikey" {
  key_vault_id = data.azurerm_key_vault.infra_key_vault.id
  name         = "grafana-api-key"
  value        = grafana_api_key.api_key.key
}

resource "grafana_folder" "folders" {
  for_each = toset(local.folders)
  title    = each.key
}
data "grafana_folder" "folder" {
  title = "amused-infra"
  depends_on = [
    grafana_folder.folders
  ]
}

###############################################################
# MS Team Message Templates
###############################################################

# {{ define "generalalert" }}
#   [Team:{{.Labels.team | toUpper }}] {{ .Labels.rulename}} - {{ .Labels.alertname }}
#   {{ if gt (len .Annotations) 0 }}
#   Annotations:
#   {{ range .Annotations.SortedPairs }}
#   - *{{ .Name }}* = {{ .Value }}
#   {{ end }}
#   {{ end }}
#   Labels:
#   {{ range .Labels.SortedPairs }}
#   - *{{ .Name }}* = {{ .Value }}
#   {{ end }}
#   {{ if gt (len .SilenceURL ) 0 }}
#   Silence alert: [Silence Url]({{ .SilenceURL }})
#   {{ end }}
#   {{ if gt (len .DashboardURL ) 0 }}
#   Go to dashboard: [Dashboard Url]({{ .DashboardURL }})
#   {{ end }}
# {{ end }}
resource "grafana_message_template" "general_alert" {
  name = "General Alert"
  # template = "{{ define \"generalalert\" }}\n  [Team:{{.Labels.team | toUpper }}] {{ .Labels.rulename}} - {{ .Labels.alertname }}\n  {{ if gt (len .Annotations) 0 }}\n  Annotations:\n  {{ range .Annotations.SortedPairs }}\n  - *{{ .Name }}* = {{ .Value }}\n  {{ end }}\n  {{ end }}\n  Labels:\n  {{ range .Labels.SortedPairs }}\n  - *{{ .Name }}* = {{ .Value }}\n  {{ end }}\n  {{ if gt (len .SilenceURL ) 0 }}\n  Silence alert: [Silence Url]({{ .SilenceURL }})\n  {{ end }}\n  {{ if gt (len .DashboardURL ) 0 }}\n  Go to dashboard: [Dashboard Url]({{ .DashboardURL }})\n  {{ end }}\n{{ end }}"
  template = "{{ define \"generalalert\" }}\n  {{ if gt (len .Annotations) 0 }}\n  {{ range .Annotations.SortedPairs }}\n  {{ if eq .Name  \"summary\" }}\n  {{ .Value }}\n  {{ end }}\n  {{ end }}  {{ end }}\n  {{ if gt (len .SilenceURL ) 0 }}\n  Silence alert: [Silence Url]({{ .SilenceURL }})\n  {{ end }}\n  {{ if gt (len .DashboardURL ) 0 }}\n  Go to dashboard: [Dashboard Url]({{ .DashboardURL }})\n  {{ end }}\n{{ end }}"
}

# {{ define "generalmessage" }}
#   {{ if gt (len .Alerts.Firing) 0 }}
#     {{ len .Alerts.Firing }} **Firing**:
#     {{ range .Alerts.Firing }} {{ template "generalalert" .}} {{ end }}
#   {{ end }}
#   {{ if gt (len .Alerts.Resolved) 0 }}
#     {{ len .Alerts.Resolved }} **Resolved**:
#     {{ range .Alerts.Resolved }} {{ template "generalalert" .}} {{ end }}
#   {{ end }}
# {{ end }}

resource "grafana_message_template" "general_message" {
  name     = "General Message"
  template = "{{ define \"generalmessage\" }}\n  {{ if gt (len .Alerts.Firing) 0 }}\n    {{ range .Alerts.Firing }} {{ template \"generalalert\" .}} {{ end }}\n  {{ end }}\n  {{ if gt (len .Alerts.Resolved) 0 }}\n    {{ range .Alerts.Resolved }} {{ template \"generalalert\" .}} {{ end }}\n  {{ end }}\n{{ end }}"
  depends_on = [
    grafana_message_template.general_alert
  ]
}

resource "grafana_contact_point" "teams_channel" {
  name = "Microsoft Teams[${var.environment}]"
  teams {
    url                     = local.teams_connectors_envs["${var.environment}"]
    message                 = "{{ template \"generalmessage\" .}}"
    title                   = "[{{ .CommonLabels.environment | toUpper  }}] | [{{ .CommonLabels.domain | toUpper }}] | {{ .CommonLabels.rulename}} - {{ .CommonLabels.alertname }}"
    disable_resolve_message = false
  }
}


resource "grafana_contact_point" "ms_teams" {
  for_each = local.teams_connectors
  name     = "Microsoft Teams[${each.key}]"
  teams {
    url                     = each.value
    message                 = "{{ template \"generalmessage\" .}}"
    title                   = "[{{ .CommonLabels.environment | toUpper  }}] | [{{ .CommonLabels.domain | toUpper }}] | {{ .CommonLabels.rulename}} - {{ .CommonLabels.alertname }}"
    disable_resolve_message = false
  }
}

resource "grafana_notification_policy" "ms_teams_alerts" {
  group_by      = ["team", "alertname"]
  contact_point = grafana_contact_point.teams_channel.name

  group_wait      = "45s"
  group_interval  = "6m"
  repeat_interval = "30m"

  dynamic "policy" {
    for_each = toset(["infra", "account", "bet", "sport", "promotion", "console", "racing"])
    content {
      matcher {
        label = "domain"
        match = "="
        value = policy.key
      }
      contact_point = grafana_contact_point.teams_channel.name
      group_by      = ["team", "og_priority", "domain", "resource_type", "environment", "alertname"]
    }
  }
  depends_on = [
    grafana_contact_point.ms_teams
  ]
}

