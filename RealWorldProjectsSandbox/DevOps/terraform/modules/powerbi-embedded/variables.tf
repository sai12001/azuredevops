variable "location" {
  description = "The name of the Resource Group where the PowerBI Embedded should be created. Changing this forces a new resource to be created."
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


variable "sku_name" {
  description = "Sets the PowerBI Embedded's pricing level's SKU. Possible values include: A1, A2, A3, A4, A5, A6"
  type        = string
}

variable "administrators" {
  description = "A set of administrator user identities, which manages the Power BI Embedded and must be a member user or a service principal in your AAD tenant."
  type        = list(string)
}

variable "pbi_mode" {
  description = "Sets the PowerBI Embedded's mode. Possible values include: Gen1, Gen2."
  type        = string
  default     = "Gen2"
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

variable "tags" {
  type        = map(any)
  description = "Common Tags of the resource"
  default     = {}
}
