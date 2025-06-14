/*
----------------------------------------------------------------------------------------------------------
Log Analytics Workspace 
----------------------------------------------------------------------------------------------------------
*/
resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name                       = "${var.context.environment}-logs-${var.context.product}-workspace-${var.context.location_abbr}"
  resource_group_name        = "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
  location                   = var.resource_group.location
  sku                        = "PerGB2018"
  retention_in_days          = var.log_analytics_retention
  daily_quota_gb             = var.environment != "global" ? 20 : -1
  internet_ingestion_enabled = var.internet_ingestion_enabled
  internet_query_enabled     = var.internet_query_enabled

  lifecycle {
    ignore_changes  = [name, location, sku, retention_in_days]
    prevent_destroy = true
  }
}

/*
----------------------------------------------------------------------------------------------------------
Solutions
----------------------------------------------------------------------------------------------------------
*/
resource "azurerm_log_analytics_solution" "DnsAnalytics" {
  solution_name         = "DnsAnalytics"
  resource_group_name   = "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
  location              = var.resource_group.location
  workspace_resource_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
  workspace_name        = azurerm_log_analytics_workspace.log_analytics_workspace.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/DnsAnalytics"
  }
  depends_on = [
    azurerm_log_analytics_workspace.log_analytics_workspace
  ]
}

resource "azurerm_log_analytics_solution" "ContainerInsights" {
  solution_name         = "ContainerInsights"
  resource_group_name   = "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
  location              = var.resource_group.location
  workspace_resource_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
  workspace_name        = azurerm_log_analytics_workspace.log_analytics_workspace.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
  depends_on = [
    azurerm_log_analytics_workspace.log_analytics_workspace
  ]
}

resource "azurerm_log_analytics_solution" "SQLVulnerabilityAssessment" {
  solution_name         = "SQLVulnerabilityAssessment"
  location              = var.resource_group.location
  resource_group_name   = "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
  workspace_resource_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
  workspace_name        = azurerm_log_analytics_workspace.log_analytics_workspace.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/SQLVulnerabilityAssessment"
  }
  depends_on = [
    azurerm_log_analytics_workspace.log_analytics_workspace
  ]
}

resource "azurerm_log_analytics_solution" "VMInsights" {
  solution_name         = "VMInsights"
  location              = var.resource_group.location
  resource_group_name   = "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
  workspace_resource_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
  workspace_name        = azurerm_log_analytics_workspace.log_analytics_workspace.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/VMInsights"
  }
  depends_on = [
    azurerm_log_analytics_workspace.log_analytics_workspace
  ]
}

resource "azurerm_log_analytics_solution" "KeyVaultAnalytics" {
  solution_name         = "KeyVaultAnalytics"
  location              = var.resource_group.location
  resource_group_name   = "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
  workspace_resource_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
  workspace_name        = azurerm_log_analytics_workspace.log_analytics_workspace.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/KeyVaultAnalytics"
  }
  depends_on = [
    azurerm_log_analytics_workspace.log_analytics_workspace
  ]
}

resource "azurerm_log_analytics_solution" "AzureSQLAnalytics" {
  solution_name         = "AzureSQLAnalytics"
  location              = var.resource_group.location
  resource_group_name   = "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
  workspace_resource_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
  workspace_name        = azurerm_log_analytics_workspace.log_analytics_workspace.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/AzureSQLAnalytics"
  }
  depends_on = [
    azurerm_log_analytics_workspace.log_analytics_workspace
  ]
}

resource "azurerm_log_analytics_solution" "Containers" {
  solution_name         = "Containers"
  location              = var.resource_group.location
  resource_group_name   = "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
  workspace_resource_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
  workspace_name        = azurerm_log_analytics_workspace.log_analytics_workspace.name
  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Containers"
  }
  depends_on = [
    azurerm_log_analytics_workspace.log_analytics_workspace
  ]
}

resource "azurerm_log_analytics_solution" "SQLAssessment" {
  solution_name         = "SQLAssessment"
  location              = var.resource_group.location
  resource_group_name   = "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
  workspace_resource_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
  workspace_name        = azurerm_log_analytics_workspace.log_analytics_workspace.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/SQLAssessment"
  }
  depends_on = [
    azurerm_log_analytics_workspace.log_analytics_workspace
  ]
}

resource "azurerm_log_analytics_solution" "Updates" {
  solution_name         = "Updates"
  location              = var.resource_group.location
  resource_group_name   = "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
  workspace_resource_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
  workspace_name        = azurerm_log_analytics_workspace.log_analytics_workspace.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Updates"
  }
  depends_on = [
    azurerm_log_analytics_workspace.log_analytics_workspace
  ]
}

resource "azurerm_log_analytics_solution" "SecurityInsights" {
  solution_name         = "SecurityInsights"
  location              = var.resource_group.location
  resource_group_name   = "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
  workspace_resource_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
  workspace_name        = azurerm_log_analytics_workspace.log_analytics_workspace.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/SecurityInsights"
  }
  depends_on = [
    azurerm_log_analytics_workspace.log_analytics_workspace
  ]
}

/*
----------------------------------------------------------------------------------------------------------
Resource Lock
----------------------------------------------------------------------------------------------------------
*/

resource "azurerm_management_lock" "log_analytics_workspace_lock" {
  name       = format("%s-lck", azurerm_log_analytics_workspace.log_analytics_workspace.name)
  scope      = azurerm_log_analytics_workspace.log_analytics_workspace.id
  lock_level = "CanNotDelete"
  notes      = "Resource Lock - Can Not Delete"

  depends_on = [
    azurerm_log_analytics_workspace.log_analytics_workspace
  ]
}