variable "context" {
  description = "The environment context for this operation"
  type = object({
    product       = string
    environment   = string
    location      = string
    location_abbr = string
  })
}

variable "environment" {
  description = "The target environment resource need to deploy to, dev,stg, pef, prd etc"
  type        = string
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
variable "firewall_name" {
  description = "Name of Firewall."
  type        = string
}

variable "firewall_sku_tier" {
  description = "SKU tier of the Firewall. Possible values are `Premium` and `Standard`."
  type        = string
}

variable "firewall_policy_id" {
  description = "ID of the Firewall Policy applied to this Firewall."
  type        = string
}

variable "firewall_availibility_zones" {
  description = "Availability zones in which the Azure Firewall should be created."
  type        = list(number)
}


#variable "firewall_dns_servers" {
#  description = "List of DNS servers that the Azure Firewall will direct DNS traffic to for the name resolution"
#  type        = list(string)
#}

#variable "firewall_private_ip_ranges" {
# description = "List of SNAT private CIDR IP ranges, or the special string `IANAPrivateRanges`, which indicates Azure Firewall does not SNAT when the destination IP address is a private range per IANA RFC 1918"
#  type        = list(string)
#}

#variable "virtual_hub_id" {
#  description = "IDs of the Virtual Hub in which to deploy the Firewall"
#  type        = string
#}

variable "tags" {
  description = "Tags need to attach to this resource"
  type        = map(string)
  default     = {}
}

variable "log_analytics_retention" {
  description = "Rentention days for log analytics"
  type        = number
  default     = 30

}