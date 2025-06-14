variable "policy_initiative_name" {
  type                  = string
  description           = "The name of the policy initiative to assign, this is NOT the display name."
}

variable "policy_initiative_id" {
  type                  = string
  description           = "The ID of the policy initiative to assign, this is NOT the display name."
}

variable "global_management_group_id" {
  type                  = string
  description           = "The UUID of the Management Group to assign the policy initiative."
}