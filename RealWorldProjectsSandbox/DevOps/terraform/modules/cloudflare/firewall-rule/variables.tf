variable "rule" {
  type = object({
    zone_id  = string
    name     = string
    action   = string
    priority = number
    filter = object({
      expression  = string
      description = optional(string)
    })
  })

  validation {
    condition = var.rule.priority > 0 && var.rule.priority <= 2000
    error_message = "rule priority must be between 1 and 2000"
  }
}
