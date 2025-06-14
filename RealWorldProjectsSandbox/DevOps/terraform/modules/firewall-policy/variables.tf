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

variable "firewall_public_ip" {
  description = "Public IP of Firewall."
  type        = list(string)
}

# variable "firewall_application_rules" {
#   description = "List of application rules to apply to firewall."
#   type        = object({ 
#     collection_priority = string
#     action              = string
#     rule                = list(object({
#        name              = string, 
#        source_addresses  = list(string), 
#        destination_fqdns = list(string), 
#     }))
#     protocols  = list(object({ 
#           type = string
#           port = string 
#          }))
#   })
# }

variable "firewall_network_rules" {
  description           = "List of network rules to apply to firewall."
  type                  = object({ 
    collection_priority = string
    action              = string
    rule                = list(object({
       name                  = string, 
       source_addresses      = list(string), 
       destination_ports     = list(string), 
       destination_addresses = list(string), 
       protocols             = list(string) 
     }))
  })
}

variable "firewall_nat_rules" {
  description           = "List of NAT rules to apply to firewall."
  type                  = object({ 
    collection_priority = string
    action              = string
    rule                = list(object({
       name                  = string, 
       source_addresses      = list(string), 
       destination_ports     = list(string), 
       destination_addresses = list(string), 
       protocols             = list(string),
       translated_address    = string,
       translated_port       = string
     }))
  })
}
