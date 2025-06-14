/*----------------------------------------------------------------------------------------------------------
Data sources
----------------------------------------------------------------------------------------------------------*/

data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}

/*----------------------------------------------------------------------------------------------------------
Microsoft Defender Plans
----------------------------------------------------------------------------------------------------------*/

# Resource Manager
resource "azurerm_security_center_subscription_pricing" "mdc_arm" {
  tier                                              = "Standard"
  resource_type                                     = "Arm"
}

# Virtual Machines
resource "azurerm_security_center_subscription_pricing" "mdc_servers" {
  tier                                              = "Standard"
  resource_type                                     = "VirtualMachines"
}

# App Services
resource "azurerm_security_center_subscription_pricing" "mdc_app_service" {
  tier                                              = "Standard"
  resource_type                                     = "AppServices"
}

# Key Vaults
resource "azurerm_security_center_subscription_pricing" "mdc_key_vault" {
  tier                                              = "Standard"
  resource_type                                     = "KeyVaults"
}

# Storage
resource "azurerm_security_center_subscription_pricing" "mdc_storage" {
  tier                                              = "Standard"
  resource_type                                     = "StorageAccounts"
}

# SQL Servers
resource "azurerm_security_center_subscription_pricing" "mdc_sql" {
  tier                                              = "Standard"
  resource_type                                     = "SqlServers"
}

# SQL Server VM's
resource "azurerm_security_center_subscription_pricing" "mdc_sql_virtual_machine" {
  tier                                              = "Standard"
  resource_type                                     = "SqlServerVirtualMachines"
}

# AKS
resource "azurerm_security_center_subscription_pricing" "mdc_aks" {
  tier                                              = "Standard"
  resource_type                                     = "KubernetesService"
}

# Container Registry
resource "azurerm_security_center_subscription_pricing" "mdc_container_registry" {
  tier                                              = "Standard"
  resource_type                                     = "ContainerRegistry"
}

# Containers
resource "azurerm_security_center_subscription_pricing" "mdc_containers" {
  tier                                              = "Standard"
  resource_type                                     = "Containers"
}

# DNS
resource "azurerm_security_center_subscription_pricing" "mdc_dns" {
  tier                                              = "Standard"
  resource_type                                     = "Dns"
}

# Open Source Relational DB's
resource "azurerm_security_center_subscription_pricing" "mdc_osrdb" {
  tier                                              = "Standard"
  resource_type                                     = "OpenSourceRelationalDatabases"
}

/*----------------------------------------------------------------------------------------------------------
Microsoft Defender Contacts
----------------------------------------------------------------------------------------------------------*/

resource "azurerm_security_center_contact" "mdc_contacts" {
  email                                             = var.mdc_contact_emails

  alert_notifications                               = var.mdc_alert_notifications
  alerts_to_admins                                  = var.mdc_alerts_to_admins
}

/*----------------------------------------------------------------------------------------------------------
Log Analytics Agent Auto Provisioning
----------------------------------------------------------------------------------------------------------*/
/*
resource "azurerm_security_center_auto_provisioning" "auto_provisioning" {
  auto_provision                                    = "On"
}
*/
/*----------------------------------------------------------------------------------------------------------
Log Analytics Agent Auto Provisioning
----------------------------------------------------------------------------------------------------------*/
/*
resource "azurerm_security_center_workspace" "log_analytics_workspace" {
  scope                                             = data.azurerm_subscription.current.id
  workspace_id                                      = var.log_analytics_workspace_id
}
*/
/*----------------------------------------------------------------------------------------------------------
MDFC Export to Log Analytics
----------------------------------------------------------------------------------------------------------*/
/*
resource "azurerm_security_center_automation" "export_log_analytics" {
  name                                              = "ExportToWorkspace"
  location                                          = var.log_analytics_workspace_location
  resource_group_name                               = var.log_analytics_workspace_rg_name

  action {
    type                                            = "loganalytics"
    resource_id                                     = var.log_analytics_workspace_id
  }

  source {
    event_source                                    = "Alerts"
    rule_set {
      rule {
        property_path       = "Severity"
        operator            = "Equals"
        expected_value      = "High"
        property_type       = "String"
      }
      rule {
        property_path       = "Severity"
        operator            = "Equals"
        expected_value      = "Medium"
        property_type       = "String"
      }
    }
  }

  source {
    event_source = "SecureScores"
  }

  source {
    event_source = "SecureScoreControls"
  }

  scopes = [data.azurerm_subscription.current.id]
}
*/
/*----------------------------------------------------------------------------------------------------------
MDFC Export to Event Hub
----------------------------------------------------------------------------------------------------------*/
/*
resource "azurerm_security_center_automation" "export_event_hub" {
  name                                              = "ExportToEventHub"
  location                                          = var.event_hub_location
  resource_group_name                               = var.event_hub_rg_name

  action {
    type                                            = "EventHub"
    resource_id                                     = var.event_hub_id
    connection_string                               = var.eventhub_connection_string
  }

  source {
    event_source                                    = "Alerts"
    rule_set {
      rule {
        property_path       = "Severity"
        operator            = "Equals"
        expected_value      = "High"
        property_type       = "String"
      }
      rule {
        property_path       = "Severity"
        operator            = "Equals"
        expected_value      = "Medium"
        property_type       = "String"
      }
    }
  }

  source {
    event_source = "SecureScores"
  }

  source {
    event_source = "SecureScoreControls"
  }

  scopes = [data.azurerm_subscription.current.id]
}
*/