
variable "template_name" {
  description = "Name of the trusted profile template"
  type        = string
}

variable "template_description" {
  description = "Description of the trusted profile template"
  type        = string
  default     = null
}

variable "policy_templates" {
  description = "List of IAM policy templates to create"
  type = list(object({
    name        = string
    description = string
    roles       = list(string)
    attributes = list(object({
      key      = string
      value    = string
      operator = string
    }))
  }))
}

variable "account_group_ids_to_assign" {
  type        = list(string)
  default     = ["all"]
  description = "A list of account group IDs to assign the template to. Support passing the string 'all' in the list to assign to all account groups."
  nullable    = false

  validation {
    condition     = contains(var.account_group_ids_to_assign, "all") ? length(var.account_group_ids_to_assign) == 1 : true
    error_message = "When specifying 'all' in the list, you cannot add any other values to the list"
  }
}

variable "profile_name" {
  description = "Name of the trusted profile inside the template"
  type        = string
}

variable "profile_description" {
  description = "Description of the trusted profile inside the template"
  type        = string
  default     = null
}

variable "identity_crn" {
  description = "CRN of the identity"
  type        = string
}
