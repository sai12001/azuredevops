variable "grafana-ai-log-based-alerts" {
  type = list(object({
    alert_name        = string
    alert_summary     = string
    alert_description = string
    team              = string
    severity          = string
    no_data_state     = optional(string)
    query             = string
  }))
  description = "Grafana AI Logs Based Alert"
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

variable "interval_seconds" {
  type = number
  description = "Rule Group Name"
}

variable "resourceGroup" {
  type = string
  description = "resourceGroup"
}

variable "resourceName" {
  type = string
  description = "resourceName"
}

variable "subscription" {
  type = string
  description = "subscription"
}

variable "resource_type" {
  type = string
  description = "resource_type"
}

variable "alert_type" {
  type = string
  description = "alert_type"
}


variable "timefor" {
  type = string
  description = "timefor"
}

variable "domain" {
  type = string
  description = "domain"
}

