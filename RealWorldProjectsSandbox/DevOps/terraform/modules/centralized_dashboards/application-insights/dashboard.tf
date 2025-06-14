resource "null_resource" "dashboard_generator" {
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "python ../../../../DevOps/terraform/modules/centralized_dashboards/application-insights/dashboard_generator.py ${var.environment} ${jsonencode(var.app_insights)} "
  }
}

data "grafana_folder" "folder" {
  title = "amused-${var.domain_name}"
}

data "azurerm_subscription" "current" {
}

data "template_file" "config_json" {
  template = file("../../../../DevOps/terraform/modules/centralized_dashboards/application-insights/dashboard_templates/cent_ai_dashboard.json")
  vars = {
    AzureDataSourceID = nonsensitive(var.AzureDataSourceID)
    SUBSCRIPTION      = data.azurerm_subscription.current.subscription_id
    dashboard_name    = "${upper(var.domain_name)} Domain App Insights"
  }
  depends_on = [
    null_resource.dashboard_generator
  ]
}

resource "grafana_dashboard" "ai_dashboard" {
  folder      = data.grafana_folder.folder.id
  config_json = data.template_file.config_json.rendered
  overwrite   = true

  depends_on = [
    null_resource.dashboard_generator
  ]
}
