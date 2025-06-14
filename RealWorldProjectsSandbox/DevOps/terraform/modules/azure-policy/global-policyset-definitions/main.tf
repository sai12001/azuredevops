#Data sources
data "azurerm_policy_definition" "locations" {
  display_name                  = "Allowed locations"
}

data "azurerm_policy_definition" "vm_la_ext" {
  display_name                  = "[Preview]: Log Analytics Extension should be enabled for listed virtual machine images"
}

data "azurerm_policy_definition" "vm_dep_agents" {
  display_name                  = "Dependency agent should be enabled for listed virtual machine images"
}

data "azurerm_policy_definition" "vmss_la_ext" {
  display_name                  = "Log Analytics extension should be enabled in virtual machine scale sets for listed virtual machine images"
}

data "azurerm_policy_definition" "vmss_dep_agents" {
  display_name                  = "Dependency agent should be enabled in virtual machine scale sets for listed virtual machine images"
}

#Policy Initiative
resource "azurerm_policy_set_definition" "global" {
  name                          = "global-policies"
  policy_type                   = "Custom"
  display_name                  = "global-policies"
  management_group_id           = var.global_management_group_id
  description                   = "Set of built-in policies that have been curated for the global management group."

    policy_definition_reference {
    // Allowed locations
    policy_definition_id        = data.azurerm_policy_definition.locations.id
    parameter_values            = <<VALUE
    {
        "listOfAllowedLocations": {
                    "value": [
                        "AustraliaEast",
                        "AustraliaSoutheast"
                    ]
                }
    }
    VALUE
  }
  policy_definition_reference {
    // Audit Log Analytics Agent Deployment - VM Image (OS) unlisted,
    policy_definition_id        = data.azurerm_policy_definition.vm_la_ext.id
    parameter_values            = <<VALUE
    {
        "listOfImageIdToInclude_windows": {
                    "value": []
                },
                "listOfImageIdToInclude_linux": {
                    "value": []
                }
    }
    VALUE
  }
  policy_definition_reference {
    // Audit Dependency agent deployment - VM Image (OS) unlisted
    policy_definition_id        = data.azurerm_policy_definition.vm_dep_agents.id
    parameter_values            = <<VALUE
    {
        "listOfImageIdToInclude_windows": {
                    "value": []
                },
                "listOfImageIdToInclude_linux": {
                    "value": [] 
                }
    }
    VALUE
  }
  policy_definition_reference {
    // Audit Log Analytics agent deployment in virtual machine scale sets - VM Image (OS) unlisted
    policy_definition_id        = data.azurerm_policy_definition.vmss_la_ext.id
    parameter_values            = <<VALUE
    {
        "listOfImageIdToInclude_windows": {
                    "value": [] 
                },
                "listOfImageIdToInclude_linux": {
                    "value": [] 
                }
    }
    VALUE
  }
  policy_definition_reference {
    // Audit Dependency agent deployment in virtual machine scale sets - VM Image (OS) unlisted
    policy_definition_id        = data.azurerm_policy_definition.vmss_dep_agents.id
    parameter_values            = <<VALUE
    {
        "listOfImageIdToInclude_windows": {
                    "value": [] 
                },
                "listOfImageIdToInclude_linux": {
                    "value": [] 
                }
    }
    VALUE
  }
  # policy_definition_reference {
  #   // Deny creation of Azure Databricks
  #   policy_definition_id        = var.databricks_id
  #   parameter_values            = <<VALUE
  #   {
  #    "defaultValue": "Deny"
  #   }
  #   VALUE
  # }
  # policy_definition_reference {
  #   // Deny creation of Azure EventHub
  #   policy_definition_id        = var.eventhub_id
  #   parameter_values            = <<VALUE
  #   {
  #    "defaultValue": "Deny"
  #   }
  #   VALUE
  # }
}