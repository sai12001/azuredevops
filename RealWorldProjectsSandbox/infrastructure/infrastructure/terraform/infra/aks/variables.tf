variable "product" {
  description = "Which product this deploy is targeting for. Injected by environment settings"
  type        = string
  default     = "ng"
}

variable "environment" {
  description = "Which environment we are deploying, supporting dev, stg, pef, prd. This value will be auto injected by terragrunt"
  type        = string
}
variable "location" {
  description = "Deployment location for cluster, support Australia East, Australia Southeast etc"
  type        = string
  default     = "australiaeast"
}

variable "location_abbr" {
  description = "Deployment location for cluster, support Australia East, Australia Southeast etc"
  type        = string
  default     = "eau"
}

variable "vnet_rg" {
  description = "The resource group where virtual network was provisioned"
  type        = string
}
variable "vnet_name" {
  description = "The name of virtual network was provisioned"
  type        = string
}

variable "subnet_name" {
  description = "The subnet where the cluster will need to provisioned and connected to"
  type        = string
}

variable "private_dns_zone" {
  description = "The private DNS zone where internal traffic will be communicating through"
  type        = string
}

variable "aks_version" {
  description = "The initial version when cluster is created. As terraform will brutely tear down cluster when update version, this maintainence will go different process"
  type        = string
}

variable "system_node_pool_min_no" {
  description = "Minimum number of nodes for system node pool"
  type        = number
  default     = 1
}

variable "system_node_pool_max_no" {
  description = "Maximum number of nodes for system node pool"
  type        = number
  default     = 2
}
variable "system_node_pool_node_size" {
  description = "The VM size for system node pool VMs"
  type        = string
  default     = "Standard_D2s_v3"
}
variable "system_node_pool_name" {
  description = "The name of system node pool"
  type        = string
  default     = "system"
}

variable "workload_node_pool_min_no" {
  description = "Minimum number of nodes for workload node pool"
  type        = number
  default     = 2
}

variable "workload_node_pool_max_no" {
  description = "Maximum number of nodes for workload node pool"
  type        = number
  default     = 5
}
variable "workload_node_pool_node_size" {
  description = "The VM size for workload node pool VMs"
  type        = string
  default     = "Standard_D4s_v3"
}
variable "workload_node_pool_name" {
  description = "The name of workload node pool"
  type        = string
  default     = "linux"
}

variable "log_workspace_id" {
  description = "The log workspace id needed for aks"
  type = string
}


variable "aks_sku_tier" {
  description = "This flag decides SLA for AKS"
  type = string
  default = "Free"
}
