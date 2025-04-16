##############################################################################
# Trusted Profile
##############################################################################

resource "ibm_iam_trusted_profile" "profile" {
  name        = var.trusted_profile_name
  description = var.trusted_profile_description
}

locals {
  # Validation of variables
  # tflint-ignore: terraform_unused_declarations
  validate_policies_one_and_only_one = [
    for i, policy in var.trusted_profile_policies : (
      (lookup(policy, "account_management", null) != null && lookup(policy, "resources", null) == null && lookup(policy, "resource_attributes", null) == null) ||
      (lookup(policy, "account_management", null) == null && lookup(policy, "resources", null) != null && lookup(policy, "resource_attributes", null) == null) ||
      (lookup(policy, "account_management", null) == null && lookup(policy, "resources", null) == null && lookup(policy, "resource_attributes", null) != null)
    ) && (policy.account_management != null || policy.resources != null || policy.resource_attributes != null) ? true :
    tobool("Values for `var.trusted_profile_policies[${i}].account_management`, `var.trusted_profile_policies[${i}].resource_attributes`, and `var.trusted_profile_policies[${i}].resources` are mutually exclusive.")
  ]

  # Transformation of maps
  policy_map = {
    for i, obj in var.trusted_profile_policies :
    "${var.trusted_profile_name}-${i}" => {
      roles              = obj.roles
      account_management = obj.account_management
      description        = obj.description
      rule_operator      = obj.rule_operator
      pattern            = obj.pattern

      resources = lookup(obj, "resources", null) == null ? {} : {
        for j, res in obj.resources :
        "${var.trusted_profile_name}-${j}-resources" => res
      }

      resource_attributes = lookup(obj, "resource_attributes", null) == null ? {} : {
        for j, res_attr in obj.resource_attributes :
        "${var.trusted_profile_name}-${j}-resource-attributes" => res_attr
      }

      resource_tags = lookup(obj, "resource_tags", null) == null ? {} : {
        for j, res_tags in obj.resource_tags :
        "${var.trusted_profile_name}-${j}-resource-tags" => res_tags
      }

      rule_conditions = lookup(obj, "rule_conditions", null) == null ? {} : {
        for j, rule_cons in obj.rule_conditions :
        "${var.trusted_profile_name}-${j}-rule-conditions" => rule_cons
      }
    }
  }
}

resource "ibm_iam_trusted_profile_policy" "policy" {
  for_each = local.policy_map

  profile_id         = ibm_iam_trusted_profile.profile.profile_id
  roles              = each.value.roles
  account_management = each.value.account_management
  description        = each.value.description
  rule_operator      = each.value.rule_operator
  pattern            = each.value.pattern

  dynamic "resources" {
    for_each = each.value.resources
    content {
      service              = resources.value.service
      service_type         = resources.value.service_type
      resource_instance_id = resources.value.resource_instance_id
      region               = resources.value.region
      resource_type        = resources.value.resource_type
      resource             = resources.value.resource
      resource_group_id    = resources.value.resource_group_id
      service_group_id     = resources.value.service_group_id
      attributes           = resources.value.attributes
    }
  }

  dynamic "resource_attributes" {
    for_each = each.value.resource_attributes
    content {
      name     = resource_attributes.value.name
      value    = resource_attributes.value.value
      operator = resource_attributes.value.operator
    }
  }

  dynamic "resource_tags" {
    for_each = each.value.resource_tags
    content {
      name     = resource_tags.value.name
      value    = resource_tags.value.value
      operator = resource_tags.value.operator
    }
  }

  dynamic "rule_conditions" {
    for_each = each.value.rule_conditions
    content {
      key      = rule_conditions.value.key
      operator = rule_conditions.value.operator
      value    = rule_conditions.value.value
    }
  }
}

locals {
  # tflint-ignore: terraform_unused_declarations
  validate_claim_type = var.trusted_profile_claim_rules == null ? [] : [
    for i, claim in var.trusted_profile_claim_rules : (
      contains(["Profile-SAML", "Profile-CR"], claim.type) ? true : tobool("Value for `var.trusted_profile_claim_rules[${i}].type must be either `Profile-SAML` or `Profile-CR`.")
    )
  ]
  # tflint-ignore: terraform_unused_declarations
  validate_claim_condition_operator = var.trusted_profile_claim_rules == null ? [] : [
    for i, claim in var.trusted_profile_claim_rules : [
      for j, condition in claim.conditions : (
        contains(["EQUALS", "NOT_EQUALS", "EQUALS_IGNORE_CASE", "NOT_EQUALS_IGNORE_CASE", "CONTAINS", "IN"], condition.operator) ?
        true : tobool("Value for `var.trusted_profile_claim_rules[${i}].conditions[${j}].operator` must be one of the following: `EQUALS`, `NOT_EQUALS`, `EQUALS_IGNORE_CASE`, `NOT_EQUALS_IGNORE_CASE`, `CONTAINS`, `IN`.")
      )
    ]
  ]
  # tflint-ignore: terraform_unused_declarations
  validate_claim_cr_type = var.trusted_profile_claim_rules == null ? [] : [
    for i, claim in var.trusted_profile_claim_rules :
    lookup(claim, "cr_type", null) == null ? true : (
      claim.type == "Profile-CR" ? true : tobool("Value for `var.trusted_profile_claim_rules[${i}].cr_type` should only be provided when `var.trusted_profile_claim_rules[${i}].type` is `Profile-CR`.")
    )
  ]
  # tflint-ignore: terraform_unused_declarations
  validate_claim_cr_type_matches = var.trusted_profile_claim_rules == null ? [] : [
    for i, claim in var.trusted_profile_claim_rules :
    lookup(claim, "cr_type", null) == null ? true : (
      contains(["VSI", "IKS_SA", "ROKS_SA"], claim.cr_type) ? true : tobool("Value for `var.trusted_profile_claim_rules[${i}].cr_type` must be one of the following: `VSI`, `IKS_SA`, `ROKS_SA`.")
    )
  ]
  # tflint-ignore: terraform_unused_declarations
  validate_claim_expiration = var.trusted_profile_claim_rules == null ? [] : [
    for i, claim in var.trusted_profile_claim_rules :
    lookup(claim, "expiration", null) == null ? true : (
      claim.type == "Profile-SAML" ? true : tobool("Value for `var.trusted_profile_claim_rules[${i}].expiration` should only be provided when `var.trusted_profile_claim_rules[${i}].type` is `Profile-SAML`.")
    )
  ]
  # tflint-ignore: terraform_unused_declarations
  validate_claim_realm_name = var.trusted_profile_claim_rules == null ? [] : [
    for i, claim in var.trusted_profile_claim_rules :
    lookup(claim, "realm_name", null) == null ? true : (
      claim.type == "Profile-SAML" ? true : tobool("Value for `var.trusted_profile_claim_rules[${i}].realm_name` should only be provided when `var.trusted_profile_claim_rules[${i}].type` is `Profile-SAML`.")
    )
  ]
  claim_map = var.trusted_profile_claim_rules == null ? {} : {
    for i, obj in var.trusted_profile_claim_rules :
    "${var.trusted_profile_name}-${i}" => {
      conditions = {
        for j, cond in obj.conditions :
        "${var.trusted_profile_name}-${j}-condition" => cond
      }
      type       = obj.type
      cr_type    = obj.cr_type
      expiration = obj.expiration
      name       = obj.name
      realm_name = obj.realm_name
    }
  }
}

resource "ibm_iam_trusted_profile_claim_rule" "claim_rule" {
  for_each = local.claim_map

  profile_id = ibm_iam_trusted_profile.profile.profile_id
  type       = each.value.type
  cr_type    = each.value.cr_type
  expiration = each.value.expiration
  name       = each.value.name
  realm_name = each.value.realm_name

  dynamic "conditions" {
    for_each = each.value.conditions
    content {
      claim    = conditions.value.claim
      operator = conditions.value.operator
      value    = conditions.value.value
    }
  }
}

locals {
  # tflint-ignore: terraform_unused_declarations
  validate_link_cr_type = var.trusted_profile_links == null ? [] : [
    for i, link in var.trusted_profile_links :
    contains(["VSI", "IKS_SA", "ROKS_SA"], link.cr_type) ? true :
    tobool("Value for `var.trusted_profile_links[${i}].cr_type must be one of the following: `VSI`, `IKS_SA`, `ROKS_SA`.")
  ]
  # tflint-ignore: terraform_unused_declarations
  validate_link_namespace = var.trusted_profile_links == null ? [] : [
    for i, link in var.trusted_profile_links : [
      for j, obj in link.links : (
        (lookup(obj, "namespace", null) == null && link.cr_type == "VSI") || link.cr_type == "ROKS_SA" || link.cr_type == "IKS_SA" ? true :
        tobool("Value for `var.trusted_profile_links[${i}].link[${j}].namespace` should only be provided if `var.trusted_profile_links[${i}].cr_type` is `IKS_SA` or `ROKS_SA`.")
      )
    ]
  ]
  # tflint-ignore: terraform_unused_declarations
  validate_link_name = var.trusted_profile_links == null ? [] : [
    for i, link in var.trusted_profile_links : [
      for j, obj in link.links :
      (lookup(obj, "name", null) == null && link.cr_type == "VSI") || link.cr_type == "ROKS_SA" || link.cr_type == "IKS_SA" ? true :
      tobool("Value for `var.trusted_profile_links[${i}].link[${j}].name` should only be provided if `var.trusted_profile_links[${i}].cr_type` is `IKS_SA` or `ROKS_SA`.")
    ]
  ]
  link_map = var.trusted_profile_links == null ? {} : merge([
    for i, obj in var.trusted_profile_links : {
      for j, link in obj.links :
      "${var.trusted_profile_name}-${i}-${j}" => {
        cr_type = obj.cr_type
        name    = obj.name
        links = {
          "${var.trusted_profile_name}-${j}-link" = link
        }
      }
    }
  ]...)
}

resource "ibm_iam_trusted_profile_link" "link" {
  for_each = local.link_map

  profile_id = ibm_iam_trusted_profile.profile.profile_id
  cr_type    = each.value.cr_type
  name       = each.value.name

  dynamic "link" {
    for_each = each.value.links
    content {
      crn       = link.value.crn
      namespace = link.value.namespace
      name      = link.value.name
    }
  }
}

resource "ibm_iam_trusted_profile_identity" "trust_identity" {
  count         = var.trusted_profile_identity == null ? 0 : 1
  profile_id    = ibm_iam_trusted_profile.profile.id
  identifier    = var.trusted_profile_identity.identifier
  identity_type = var.trusted_profile_identity.identity_type
  type          = var.trusted_profile_identity.type
  accounts      = var.trusted_profile_identity.type == "user" && contains(keys(var.trusted_profile_identity), "accounts") ? var.trusted_profile_identity.accounts : null
  description   = try(var.trusted_profile_identity.description, null)
}

