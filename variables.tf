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


  validation {
    condition = alltrue([
      for i, policy in var.trusted_profile_policies : (
        length(compact([
          (lookup(policy, "account_management", null) != null ? "account_management" : null),
          (lookup(policy, "resources", null) != null ? "resources" : null),
          (lookup(policy, "resource_attributes", null) != null ? "resource_attributes" : null)
        ])) == 1
      )
    ])
    error_message = "Each trusted_profile_policy must have exactly one of `account_management`, `resources`, or `resource_attributes` set and non-null. These are mutually exclusive."
  }


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

  default = []

  validation {
    condition = var.trusted_profile_claim_rules == null ? true : (
      length([
        for i, claim in var.trusted_profile_claim_rules : (
          contains(["Profile-SAML", "Profile-CR"], claim.type)
        )
      ]) == length(var.trusted_profile_claim_rules)
    )
    error_message = "Each value in `var.trusted_profile_claim_rules.type` must be either `Profile-SAML` or `Profile-CR`."
  }

  validation {
    condition = (
      alltrue(flatten([
        for claim in var.trusted_profile_claim_rules : [
          for condition in claim.conditions :
          contains(["EQUALS", "NOT_EQUALS", "EQUALS_IGNORE_CASE", "NOT_EQUALS_IGNORE_CASE", "CONTAINS", "IN"], condition.operator)
        ]
      ]))
    )
    error_message = "Each item in `var.trusted_profile_claim_rules.conditions.operator` must be one of the following: `EQUALS`, `NOT_EQUALS`, `EQUALS_IGNORE_CASE`, `NOT_EQUALS_IGNORE_CASE`, `CONTAINS`, `IN`."
  }

  validation {
  condition = (
    var.trusted_profile_claim_rules == null ? true :
    alltrue([
      for i, claim in var.trusted_profile_claim_rules :
      !(try(claim.cr_type != null && claim.type != "Profile-CR", false))
    ])
  )
  error_message = "Field `cr_type` should only be set when `type` is `Profile-CR`."
}
  
  validation {
  condition = (
    var.trusted_profile_claim_rules == null ? true :
    alltrue([
      for claim in var.trusted_profile_claim_rules :
      claim.cr_type == null || try(contains(["VSI", "IKS_SA", "ROKS_SA"], claim.cr_type), false)
    ])
  )
  error_message = "If `cr_type` is provided, it must be one of: `VSI`, `IKS_SA`, `ROKS_SA`."
}

validation {
  condition = (
    var.trusted_profile_claim_rules == null ? true :
    alltrue([
      for claim in var.trusted_profile_claim_rules :
      (
        !(contains(keys(claim), "expiration")) || claim.type == "Profile-SAML"
      )
    ])
  )
  error_message = "If `expiration` is provided, then `type` must be `Profile-SAML`."
}


  validation {
  condition = (
    var.trusted_profile_claim_rules == null ? true :
    alltrue([
      for claim in var.trusted_profile_claim_rules :
      claim.realm_name == null || claim.type == "Profile-SAML"
    ])
  )
  error_message = "If `realm_name` is provided, then `type` must be `Profile-SAML`."
}
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

  default = []

  validation {
    condition = (
      var.trusted_profile_links == null || alltrue([
        for link in var.trusted_profile_links :
        contains(["VSI", "IKS_SA", "ROKS_SA"], link.cr_type)
      ])
    )
    error_message = "Each `cr_type` in `trusted_profile_links` must be one of the following: `VSI`, `IKS_SA`, `ROKS_SA`."
  }

validation {
  condition = (
    var.trusted_profile_links == null || alltrue(flatten([
      for link in var.trusted_profile_links : [
        for obj in link.links :
        (
          (lookup(obj, "namespace", null) == null && link.cr_type == "VSI") ||
          (link.cr_type == "ROKS_SA" || link.cr_type == "IKS_SA")
        )
      ]
    ]))
  )
  error_message = "A `namespace` in `links` should only be provided if `cr_type` is `IKS_SA` or `ROKS_SA`."
}


  validation {
    condition = (
      var.trusted_profile_links == null || alltrue(flatten([
        for i, link in var.trusted_profile_links : [
          for j, obj in link.links :
          (lookup(obj, "name", null) == null && link.cr_type == "VSI") || link.cr_type == "ROKS_SA" || link.cr_type == "IKS_SA"
        ]
        ]))
    )
    error_message = "A `name` in `links` should only be provided if `cr_type` is `IKS_SA` or `ROKS_SA`."
  }


}
