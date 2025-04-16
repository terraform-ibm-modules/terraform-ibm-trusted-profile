
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
    service     = string
  }))
}

variable "onboard_all_account_groups" {
  type        = bool
  default     = true
  description = "Whether to onboard all account groups to the template."
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


