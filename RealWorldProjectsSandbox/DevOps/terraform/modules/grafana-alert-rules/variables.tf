variable "grafana_metric_alert" {
  type = map(object({
    alert_name        = string
    alert_summary     = string
    alert_description = string
    domain            = string
    team              = string
    severity          = string
    resource_type     = string
    alert_type        = string
    metricName        = string
    dimensionFilters  = optional(any)
    aggregation       = optional(string)
    no_data_state     = optional(string)
    metric_threshold  = number
    timefor           = string
    interval_seconds  = number
    folderuid         = string
    resourceGroup     = string
    resourceName      = string
    metricNamespace   = string
    subscription      = string
    trigger_eval_type = optional(string)
  }))
  description = "Grafana Metric Alert"
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