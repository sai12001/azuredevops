locals {
  automanange_profile_name = "${var.context.environment}-automanage-${var.context.product}-infra-shared-${var.context.location_abbr}"  
  log_workspace           = {
    name                  = "${var.context.environment}-logs-${var.context.product}-workspace-${var.context.location_abbr}"
    resource_group_name   = "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
  }
}
#----------------------------------------------------------------------------------------------------------
#Data sources
#----------------------------------------------------------------------------------------------------------
data "azurerm_resource_group" "rg" {
  name = local.log_workspace.resource_group_name
}
#----------------------------------------------------------------------------------------------------------
#Automanage Profile
#----------------------------------------------------------------------------------------------------------
resource "azapi_resource" "automanage" {
  type      = "Microsoft.Automanage/configurationProfiles@2022-05-04"
  name      = local.automanange_profile_name
  location  = "australiaeast"
  parent_id = data.azurerm_resource_group.rg.id
  body = jsonencode({
     properties = {
       configuration = {
              "Antimalware/Enable": true
              "Antimalware/EnableRealTimeProtection": true
              "Antimalware/RunScheduledScan": true
              "Antimalware/ScanType": "Quick"
              "Antimalware/ScanDay": 7
              "Antimalware/ScanTimeInMinutes": 120
              "AzureSecurityBaseline/Enable": true
              "AzureSecurityBaseline/AssignmentType": "ApplyAndAutoCorrect"
              "AzureSecurityCenter/Enable": true
              "Backup/Enable": true
              "Backup/PolicyName": "dailyBackupPolicy"
              "Backup/TimeZone": "AUS Eastern Standard Time"
              "Backup/InstantRpRetentionRangeInDays": 2
              "Backup/SchedulePolicy/ScheduleRunFrequency": "Daily"
              "Backup/SchedulePolicy/ScheduleRunTimes": [
                "2022-11-17T01:00:00Z",
                ]
              "Backup/SchedulePolicy/SchedulePolicyType": "SimpleSchedulePolicy"
              "Backup/RetentionPolicy/RetentionPolicyType": "LongTermRetentionPolicy"
              "Backup/RetentionPolicy/DailySchedule/RetentionTimes": [
                  "2022-11-17T01:00:00Z"
              ]
              "Backup/RetentionPolicy/DailySchedule/RetentionDuration/Count": 7
              "Backup/RetentionPolicy/DailySchedule/RetentionDuration/DurationType": "Days"
              "BootDiagnostics/Enable": true
              "ChangeTrackingAndInventory/Enable": true
              "LogAnalytics/Enable": true
              "UpdateManagement/Enable": true
              "VMInsights/Enable": true
        }
     }
   })
}