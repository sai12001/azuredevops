
variable "context" {
  description = "The environment context for this operation"
  type = object({
    product       = string
    environment   = string
    location      = string
    location_abbr = string
  })
}

#TODO: validation, it must lower case and support alphabet and dash only

variable "domain" {
  description = "The logic domain this app service plan belongs to, racing, betplacement etc"
  type        = string
}

variable "team" {
  description = "The team related to this domain"
  type        = string
}

variable "datasource_id" {
  description = "datasource_id"
  type        = string
}