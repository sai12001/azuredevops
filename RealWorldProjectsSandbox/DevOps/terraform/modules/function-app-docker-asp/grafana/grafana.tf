#----------------------------------------------------------------------------------------------------------
# Synthetic Testing 
#----------------------------------------------------------------------------------------------------------

data "grafana_synthetic_monitoring_probes" "main" {
}


resource "grafana_synthetic_monitoring_check" "http" {
  job     = var.domain
  target  = "https://${var.function_app_name}.azurewebsites.net"
  enabled = true
  probes = [
    data.grafana_synthetic_monitoring_probes.main.probes["${var.context.environment}_private_probe"],
  ]
  labels = var.tags
  settings {
    http {}
  }
  lifecycle {
    ignore_changes = [probes]
  }
}