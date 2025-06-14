# variable "eventhub_id" {
#   type              = string
#   description       = "The UUID of Azure Eventhub policy."
# }
# variable "databricks_id" {
#   type              = string
#   description       = "The UUID of Azure Databricks policy."
# }
variable "global_management_group_id" {
  type              = string
  description       = "The UUID of the Management Group to assign the policy initiative."
}