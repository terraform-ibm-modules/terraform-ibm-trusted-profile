########################################################################################################################
# Input Variables
########################################################################################################################

variable "trusted_profile_name" {
  type        = string
  description = "Name of the trusted profile."
}

variable "trusted_profile_description" {
  type        = string
  description = "Description of the trusted profile."
  default     = null
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

  # validation {
  #   condition = contains(["Profile-SAML", "Profile-CR"], var.trusted_profile_claim_rules[*].type)
  #   error_message = "Value for `var.trusted_profile_claim_rules[*].type must be either `Profile-SAML` or `Profile-CR`."
  # }

  # validation {
  #   condition = contains(["EQUALS", "NOT_EQUALS", "EQUALS_IGNORE_CASE", "NOT_EQUALS_IGNORE_CASE", "CONTAINS", "IN"], var.trusted_profile_claim_rules[*].conditions[*].operator)
  #   error_message = "Value for `var.trusted_profile_claim_rules[*].conditions[*].operator` must be one of the following: `EQUALS`, `NOT_EQUALS`, `EQUALS_IGNORE_CASE`, `NOT_EQUALS_IGNORE_CASE`, `CONTAINS`, `IN`."
  # }

  # validation {
  #   condition = (
  #     var.trusted_profile_claim_rules[*].cr_type == null ? true : var.trusted_profile_claim_rules[*].type == "Profile-CR"
  #   )
  #   error_message = "Value for `var.trusted_profile_claim_rules[*].cr_type` should only be provided when `var.trusted_profile_claim_rules[*].type` is `Profile-CR`."
  # }

  # validation {
  #   condition = (
  #     var.trusted_profile_claim_rules[*].cr_type == null ? true : (
  #       contains(["VSI", "IKS_SA", "ROKS_SA"], var.trusted_profile_claim_rules[*].cr_type)
  #     )
  #   )
  #   error_message = "Value for `var.trusted_profile_claim_rules[*].cr_type` must be one of the following: `VSI`, `IKS_SA`, `ROKS_SA`."
  # }

  # validation {
  #   condition = (
  #     var.trusted_profile_claim_rules[*].expiration == null ? true : var.trusted_profile_claim_rules[*].type == "Profile-SAML"
  #   )
  #   error_message = "Value for `var.trusted_profile_claim_rules[*].expiration` should only be provided when `var.trusted_profile_claim_rules[*].type` is `Profile-SAML`."
  # }

  # validation {
  #   condition = (
  #     var.trusted_profile_claim_rules[*].realm_name == null ? true : var.trusted_profile_claim_rules[*].type == "Profile-SAML"
  #   )
  #   error_message = "Value for `var.trusted_profile_claim_rules[*].realm_name` should only be provided when `var.trusted_profile_claim_rules[*].type` is `Profile-SAML`."
  # }
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

  # validation {
  #   condition = (
  #     contains(["VSI", "IKS_SA", "ROKS_SA"], var.trusted_profile_links[*].cr_type)
  #   )
  #   error_message = "Value for `var.trusted_profile_links[*].cr_type must be one of the following: `VSI`, `IKS_SA`, `ROKS_SA`."
  # }

  # validation {
  #   condition = (
  #     var.trusted_profile_links[*].link[*].namespace != null && var.trusted_profile_links[*].cr_type != "VSI"
  #   )
  #   error_message = "Value for `var.trusted_profile_links[*].link[*].namespace` should only be provided if `var.trusted_profile_links[*].cr_type` is `IKS_SA` or `ROKS_SA`."
  # }

  # validation {
  #   condition = (
  #     var.trusted_profile_links[*].link[*].name != null && var.trusted_profile_links[*].cr_type != "VSI"
  #   )
  #   error_message = "Value for `var.trusted_profile_links[*].link[*].name` should only be provided if `var.trusted_profile_links[*].cr_type` is `IKS_SA` or `ROKS_SA`."
  # }
}
