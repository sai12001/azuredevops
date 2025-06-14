resource "null_resource" "dashboard_generator" {
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "python ../../../../DevOps/terraform/modules/centralized_dashboards/cosmos-db/dashboard_generator.py ${var.environment} ${jsonencode(var.cosmosdbs)} "
  }
}

data "grafana_folder" "folder" {
  title = "amused-${var.domain_name}"
}

data "azurerm_subscription" "current" {
}


data "template_file" "config_json" {
  template = file("../../../../DevOps/terraform/modules/centralized_dashboards/cosmos-db/dashboard_templates/cent_docdb_dashboard.json")
  vars = {
    AzureDataSourceID = nonsensitive(var.AzureDataSourceID)
    SUBSCRIPTION      = data.azurerm_subscription.current.subscription_id
    dashboard_name    = var.dashboard_name
    dimension         = "$${__field.labels.__values}"
  }
  depends_on = [
    null_resource.dashboard_generator
  ]
}


resource "grafana_dashboard" "docdb_dashboard" {
  folder      = data.grafana_folder.folder.id
  config_json = data.template_file.config_json.rendered
  overwrite   = true
  # lifecycle {
  #   ignore_changes = [config_json]
  # }
  depends_on = [
    null_resource.dashboard_generator
  ]
}
