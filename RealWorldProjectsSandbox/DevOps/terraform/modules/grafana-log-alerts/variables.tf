variable "grafana_log_alerts" {
  type = map(object({
    alert_name        = string
    alert_summary     = string
    alert_description = string
    domain            = string
    team              = string
    severity          = string
    resource_type     = string
    alert_type        = string
    no_data_state     = optional(string)
    timefor           = string
    interval_seconds  = number
    folderuid         = string
    resourceGroup     = string
    resourceName      = string
    subscription      = string
    query             = string
    threshold         = optional(number)
  }))
  description = "Grafana Log Alert"
}

variable "datasource_uid" {
  type        = string
  description = "datasource uid"
}

variable "environment" {
  type        = string
  description = "environment"

}

variable "folder_uid" {
  type = string
  description = "Folder id"
  
}

variable "rule_group_name" {
  type = string
  description = "Rule Group Name"
}