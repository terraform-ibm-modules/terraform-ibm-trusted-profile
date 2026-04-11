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
  description = "A list of account group IDs to assign the template to. Use ['all'] to assign to all account groups (requires enterprise account)."
  nullable    = false
}

variable "account_ids_to_assign" {
  type        = list(string)
  default     = []
  description = "A list of account IDs to assign the template to. Use ['all'] to assign to all accounts (requires enterprise account)."
  nullable    = false
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

variable "identities" {
  description = "List of identity blocks with type, iam_id, and identifier"
  type = list(object({
    type       = string
    iam_id     = string
    identifier = string
  }))
  default  = []
  nullable = false

  validation {
    condition     = alltrue([for i in var.identities : contains(["crn", "user", "serviceid"], i.type)])
    error_message = "Each identity must have a valid type: crn, user, or serviceid."
  }

  # From IAM team -> ibmid of crn is composed with prefix crn and crn of an resource.
  # ibmid of serviceid is composed with prefix iam- and ServiceId
  validation {
    condition = alltrue([
      for i in var.identities :
      i.type == "user" ? can(regex("^IBMid-", i.iam_id)) :
      i.type == "serviceid" ? can(regex("^iam-ServiceId-", i.iam_id)) :
      i.type == "crn" ? can(regex("^crn-crn:", i.iam_id)) :
      true
    ])
    error_message = "IAM ID must start with 'IBMid-' for type 'user' and 'iam-ServiceId-' for type 'serviceid' and 'crn-crn:' for type 'crn'."
  }

  validation {
    condition = alltrue([
      for i in var.identities :
      i.type == "user" ? can(regex("^IBMid-", i.identifier)) :
      i.type == "serviceid" ? can(regex("^ServiceId-", i.identifier)) :
      i.type == "crn" ? can(regex("^crn:", i.identifier)) :
      true
    ])
    error_message = "Identifier format must match the identity type: email for 'user', 'ServiceId-*' for 'serviceid', and must start with 'crn:' for 'crn'."
  }
}
