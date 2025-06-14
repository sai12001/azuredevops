#Policy Definitions
resource "azurerm_policy_definition" "deny_azure_databricks" {
   name         = "Deny creation of Azure Databricks Resources"
   policy_type  = "Custom"
   mode         = "All"
   display_name = "Deny creation of Azure Databricks Resources"
   
   metadata = <<METADATA
    {
       "version": "1.0.0",
       "category": "Azure Databricks"
    }
    METADATA
   policy_rule = <<POLICY_RULE
   {
       "if": {
              "field"  : "type",
              "equals" : "Microsoft.Databricks/*"
        
        },
        "then": {
          "effect": "[parameters('effect')]"
        }
   }
   POLICY_RULE
   parameters = <<PARAMETERS
    {
    "effect": {
        "type": "String",
        "allowedValues": [
            "Audit",
            "Deny",
            "Disabled"
        ],
        "defaultValue": "Deny",
        "metadata": {
            "displayName": "Effect",
            "description": "Enable or disable the execution of the policy"
        }
    }
    }
   PARAMETERS
}
resource "azurerm_policy_definition" "deny_azure_eventhub" {
   name         = "Deny creation of Azure Event Hub Resources"
   policy_type  = "Custom"
   mode         = "All"
   display_name = "Deny creation of Azure Event Hub Resources"
   
   metadata = <<METADATA
    {
       "version": "1.0.0",
       "category": "Event Hub"
    }
    METADATA
   policy_rule = <<POLICY_RULE
   {
       "if": {
              "field"  : "type",
              "equals" : "Microsoft.EventHub/*"
        
        },
        "then": {
          "effect": "[parameters('effect')]"
        }
   }
   POLICY_RULE
   parameters = <<PARAMETERS
    {
    "effect": {
        "type": "String",
        "allowedValues": [
            "Audit",
            "Deny",
            "Disabled"
        ],
        "defaultValue": "Deny",
        "metadata": {
            "displayName": "Effect",
            "description": "Enable or disable the execution of the policy"
        }
    }
    }
   PARAMETERS
}