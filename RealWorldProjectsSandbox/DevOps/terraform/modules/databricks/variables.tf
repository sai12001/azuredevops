variable "enable_databricks_autoscale" {
  type        = bool
  description = "Set it true if autoscaling is required for databricks cluster"
  default     = true
}

variable "enable_databricks_azure_attributes" {
  type        = bool
  description = "Set it true if azure attributes are needed to be set for creating databricks cluster"
  default     = true
}

variable "databricks_workspace_name" {
  type        = string
  description = "The databricks workspace name"
}

variable "location" {
  type        = string
  description = "Location where resources should be deployed"
}

variable "location_abbr" {
  description = "Deployment location for cluster, support Australia East, Australia Southeast etc"
  type        = string
}

variable "databricks_sku" {
  type        = string
  description = "The sku to use for the Databricks Workspace. Possible values are standard, premium, or trial. Changing this can force a new resource to be created in some circumstances."
  default     = "standard"
}

variable "tags" {
  type        = map(any)
  description = "Common Tags of the resource"
  default     = {}
}

variable "is_customer_managed_key_enabled" {
  type        = bool
  description = "Is the workspace enabled for customer managed key encryption? If true this enables the Managed Identity for the managed storage account. Possible values are true or false. Defaults to false. This field is only valid if the Databricks Workspace sku is set to premium. Changing this forces a new resource to be created."
  default     = false
}


variable "is_public_network_access_enabled" {
  type        = bool
  description = "Allow public access for accessing workspace. Set value to false to access workspace only via private link endpoint. Possible values include true or false. Defaults to true. Changing this forces a new resource to be created."
  default     = true
}

variable "required_nsg_rules" {
  type        = string
  description = "Does the data plane (clusters) to control plane communication happen over private link endpoint only or publicly? Possible values AllRules, NoAzureDatabricksRules or NoAzureServiceRules. Required when public_network_access_enabled is set to false. Changing this forces a new resource to be created."
  default     = "AllRules"
}

variable "machine_learning_workspace_id" {
  type        = string
  description = "The ID of a Azure Machine Learning workspace to link with Databricks workspace. Changing this forces a new resource to be created."
  default     = null
}

variable "no_public_ip" {
  type        = bool
  description = "Are public IP Addresses not allowed? Possible values are true or false."
  default     = true
}

variable "public_ip_name" {
  type        = string
  description = " Name of the Public IP for No Public IP workspace with managed vNet. Defaults to nat-gw-public-ip. Changing this forces a new resource to be created."
  default     = "pip-ng-databricks-gw"
}

variable "create_databricks_in_own_vnet" {
  type        = bool
  description = "Creates databricks in own vnet if set to true"
  default     = true
}

variable "public_subnet_name" {
  type        = string
  description = "Name of the public subnet for databricks. Required if virtual_network_id is set i.e. m_create_databricks_in_own_vnet is set to true"
}

variable "private_subnet_name" {
  type        = string
  description = "Name of the private subnet for databricks. Required if virtual_network_id is set i.e. m_create_databricks_in_own_vnet is set to true"
}

variable "nsg_databricks" {
  type        = string
  description = "ID of the existing NSG to be used"
  default     = ""
}

variable "storage_account_sku_name" {
  type        = string
  description = "Storage account SKU name. Possible values include Standard_LRS, Standard_GRS, Standard_RAGRS, Standard_GZRS, Standard_RAGZRS, Standard_ZRS, Premium_LRS or Premium_ZRS. Defaults to Standard_GRS. Changing this forces a new resource to be created"
  default     = "Standard_GRS"
}


variable "enable_databricks_cluster" {
  type        = bool
  description = "Creates databricks cluster is set to true"
  default     = true
}


variable "databricks_spark_version" {
  type        = string
  description = "Runtime version of the cluster. Any supported databricks_spark_version id. We advise using Cluster Policies to restrict the list of versions for simplicity while maintaining enough control."
  default     = "8.3.x-scala2.12"
}


variable "databricks_node_type_id" {
  type        = string
  description = "Any supported databricks_node_type id. If instance_pool_id is specified, this field is not needed."
  default     = "Standard_DS3_v2"
}


variable "databricks_autotermination_minutes" {
  type        = string
  description = "Automatically terminate the cluster after being inactive for this time in minutes. If specified, the threshold must be between 10 and 10000 minutes. You can also set this value to 0 to explicitly disable automatic termination. Defaults to 60. We highly recommend having this setting present for Interactive/BI clusters."
  default     = "0"
}

variable "databricks_driver_node_type_id" {
  type        = string
  description = "The node type of the Spark driver. This field is optional; if unset, API will set the driver node type to the same value as m_databricks_node_type_id defined above."
  default     = "Standard_DS3_v2"
}


variable "databricks_min_workers" {
  type        = string
  description = "The minimum number of workers to which the cluster can scale down when underutilized. It is also the initial number of workers the cluster will have after creation."
  default     = "2"
}

variable "databricks_max_workers" {
  type        = string
  description = "The maximum number of workers to which the cluster can scale up when overloaded. max_workers must be strictly greater than min_workers."
  default     = "3"
}

variable "databricks_availability" {
  type        = string
  description = "Availability type used for all subsequent nodes past the first_on_demand ones. Valid values are SPOT_AZURE, SPOT_WITH_FALLBACK_AZURE, and ON_DEMAND_AZURE. Note: If first_on_demand is zero, this availability type will be used for the entire cluster."
  default     = "ON_DEMAND_AZURE"
}

variable "databricks_first_on_demand" {
  type        = string
  description = "The first first_on_demand nodes of the cluster will be placed on on-demand instances. If this value is greater than 0, the cluster driver node will be placed on an on-demand instance. If this value is greater than or equal to the current cluster size, all nodes will be placed on on-demand instances. If this value is less than the current cluster size, first_on_demand nodes will be placed on on-demand instances, and the remainder will be placed on availability instances. This value does not affect cluster size and cannot be mutated over the lifetime of a cluster."
  default     = "1"
}

variable "databricks_spot_bid_max_price" {
  type        = string
  description = "The max price for Azure spot instances. Use -1 to specify the lowest price."
  default     = "-1"
}

variable "databricks_num_workers" {
  type        = string
  description = "Specifies the number of workers to which the cluster can scale up when overloaded"
  default     = "2"
}


variable "databricks_spark_conf_keys" {
  type        = list(string)
  description = "Specifies the key of the spark config that is to be passed for creating databricks cluster"
  default     = []
}

variable "databricks_spark_confs_vals" {
  type        = list(string)
  description = "Specifies the value of the spark config that is to be passed for creating databricks cluster"
  default     = []
}

variable "databricks_tag_keys" {
  type        = list(string)
  description = "Specifies the key of the custom tag that is to be passed while creating databricks cluster"
  default     = []
}

variable "databricks_tag_vals" {
  type        = list(string)
  description = "Specifies the value of the custom tag that is to be passed while creating databricks cluster"
  default     = []
}

variable "databricks_spark_env_keys" {
  type        = list(string)
  description = "Specifies the key of the spark environment variable that is to be passed for creating databricks cluster"
  default     = []
}

variable "databricks_spark_env_vals" {
  type        = list(string)
  description = "Specifies the value of the spark environment variable that is to be passed for creating databricks cluster"
  default     = []
}

variable "vnet_name" {
  type        = string
  description = "Reference to a subnet's VNET Name in which NIC is created"
}

variable "vnet_resource_group" {
  type        = string
  description = "Resource Group of VNET in which this NIC is created"
}

variable "resource_group" {
  description = "Resoruce group object where this resource will deploy to, it suppose pass from resource group output"
  type = object({
    name          = string
    tags          = map(string)
    location      = string
    location_abbr = string
  })
}

variable "context" {
  description = "The environment context for this operation"
  type = object({
    product       = string
    environment   = string
    domain        = string
    location      = string
    location_abbr = string
  })
}

variable "domain_name" {
  type    = string
  default = "infra"
}

variable "network_security_group_rules" {
  description = "Security rules for the network security group using this format name = [priority, direction, access, protocol, source_port_range, destination_port_range, source_address_prefix, destination_address_prefix, description]"
  type = list(object({
    name                         = string
    priority                     = number
    direction                    = string
    access                       = string
    protocol                     = string
    source_port_range            = string
    destination_port_range       = string
    source_address_prefix        = optional(string)
    source_address_prefixes      = optional(list(string))
    destination_address_prefix   = optional(string)
    destination_address_prefixes = optional(list(string))
    description                  = string
  }))
  default = []
}

variable "log_analytics_retention" {
  description = "Rentention days for log analytics"
  type        = number
  default     = 30

}

variable "containers" {
  description = "Containers used by Data Lake"
  type = list(object({
    name        = string
    access_type = string
  }))
  default = []

}

variable "blobs" {
  description = "Blobs to create directory structure used by Data Lake"
  type = map(object({
    name           = string,
    container_name = string,
    type           = string
  }))
  default = {}
}

variable "python_library_protobuf" {
  description = "Python used in the Cluster"
  type    = string
  default = "protobuf==3.20.1"
}

variable "python_library_pyarrow" {
  description = "Python used in the Cluster"
  type    = string
  default = "pyarrow==11.0.0"
}

variable "python_library_opencensus" {
  description = "Python used in the Cluster"
  type    = string
  default = "opencensus==0.11.1"
}
variable "python_library_opencensus_ext_azure" {
  description = "Python used in the Cluster"
  type    = string
  default = "opencensus-ext-azure==1.1.8"
}

variable "maven_library" {
  type    = string
  default = "com.microsoft.azure:azure-eventhubs-spark_2.12:2.3.18"
}

variable "task_configuration" {
  description = "Workflow configuration"

  type = list(object({
    name                   = string
    max_concurrent_runs    = number
    quartz_cron_expression = string
    timezone_id            = string
    url                    = string
    task_key               = string
    notebook_path          = string
  }))
  default = [] 
}

variable "task_configuration_one_off" {
  description = "Task configuration for continuous execution"

  type = list(object({
    name                   = string
    max_concurrent_runs    = number
    timezone_id            = string
    url                    = string
    task_key               = string
    notebook_path          = string
  }))
  default = [] 
}

variable "branch" {
  description = "Defines branch to be used for Databricks"
  type    = string
}