########################################################################################################################
# Input Variables
########################################################################################################################

variable "custom_role_name" {
  description = "Optional custom role to include in profile policies"
  type        = string
  default     = null
}

variable "trusted_profile_name" {
  type        = string
  description = "Name of the trusted profile."
}

variable "trusted_profile_description" {
  type        = string
  description = "Description of the trusted profile."
  default     = null
}

variable "create_trusted_relationship" {
  description = "Whether to create a trusted profile identity (trust relationship)."
  type        = bool
  default     = false
}

variable "trusted_profile_identity" {
  description = "The identity to trust (required if create_trusted_relationship is true)"
  type = object({
    identifier    = string
    identity_type = string
    type          = string
  })
  default = null
}


variable "trusted_profile_policies" {
  type = list(object({
    roles              = list(string)
    account_management = optional(bool)
    description        = optional(string)

    resources = optional(list(object({
      service              = optional(string)
      service_type         = optional(string)
      resource_instance_id = optional(string)
      region               = optional(string)
      resource_type        = optional(string)
      resource             = optional(string)
      resource_group_id    = optional(string)
      service_group_id     = optional(string)
      attributes           = optional(map(any))
    })), null)

    resource_attributes = optional(list(object({
      name     = string
      value    = string
      operator = optional(string)
    })))

    resource_tags = optional(list(object({
      name     = string
      value    = string
      operator = optional(string)
    })))

    rule_conditions = optional(list(object({
      key      = string
      operator = string
      value    = list(any)
    })))

    rule_operator = optional(string)
    pattern       = optional(string)
  }))
  description = "A list of Trusted Profile Policy objects that are applied to the Trusted Profile created by the module."
}

variable "trusted_profile_claim_rules" {
  type = list(object({
    # required arguments
    conditions = list(object({
      claim    = string
      operator = string
      value    = string
    }))

    type = string

    # optional arguments
    cr_type    = optional(string)
    expiration = optional(number)
    name       = optional(string)
    realm_name = optional(string)
  }))

  description = "A list of Trusted Profile Claim Rule objects that are applied to the Trusted Profile created by the module."

  default = null
}

variable "trusted_profile_links" {
  type = list(object({
    # required arguments
    cr_type = string
    links = list(object({
      crn       = string
      namespace = optional(string)
      name      = optional(string)
    }))

    # optional arguments
    name = optional(string)
  }))

  description = "A list of Trusted Profile Link objects that are applied to the Trusted Profile created by the module."

  default = null
}
