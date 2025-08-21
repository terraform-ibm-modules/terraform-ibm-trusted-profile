##############################################################################
# Trusted Profile
##############################################################################

resource "ibm_iam_trusted_profile" "profile" {
  name        = var.trusted_profile_name
  description = var.trusted_profile_description
}

locals {
  policy_map = {
    for i, obj in var.trusted_profile_policies :
    obj.unique_identifier => {
      roles              = obj.roles
      account_management = obj.account_management
      description        = obj.description
      rule_operator      = obj.rule_operator
      pattern            = obj.pattern

      resources = lookup(obj, "resources", null) == null ? {} : {
        for j, res in obj.resources :
        "${obj.unique_identifier}-${j}-resources" => res
      }

      resource_attributes = lookup(obj, "resource_attributes", null) == null ? {} : {
        for j, res_attr in obj.resource_attributes :
        "${obj.unique_identifier}-${j}-resource-attributes" => res_attr
      }

      resource_tags = lookup(obj, "resource_tags", null) == null ? {} : {
        for j, res_tags in obj.resource_tags :
        "${obj.unique_identifier}-${j}-resource-tags" => res_tags
      }

      rule_conditions = lookup(obj, "rule_conditions", null) == null ? {} : {
        for j, rule_cons in obj.rule_conditions :
        "${obj.unique_identifier}-${j}-rule-conditions" => rule_cons
      }
    }
  }
}

resource "ibm_iam_trusted_profile_policy" "policy" {
  for_each = local.policy_map

  iam_id             = ibm_iam_trusted_profile.profile.profile_id
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
  claim_map = var.trusted_profile_claim_rules == null ? {} : {
    for i, obj in var.trusted_profile_claim_rules :
    obj.unique_identifier => {
      conditions = {
        for j, cond in obj.conditions :
        "${obj.unique_identifier}-${j}-condition" => cond
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
  link_map = var.trusted_profile_links == null ? {} : merge([
    for i, obj in var.trusted_profile_links : {
      for j, link in obj.links :
      "${obj.unique_identifier}-${j}" => {
        cr_type = obj.cr_type
        name    = obj.name
        links = {
          "${obj.unique_identifier}-${j}-link" = link
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
      # A link name should only be passed if 'cr_type' is 'IKS_SA' or 'ROKS_SA',
      # other wise provider fails with 'CreateLinkWithContext failed: Invalid property combination provided.'
      name = each.value.cr_type == "IKS_SA" || each.value.cr_type == "ROKS_SA" ? link.value.name : null
    }
  }
}

resource "ibm_iam_trusted_profile_identity" "trust_identity" {
  count      = var.trusted_profile_identity == null ? 0 : 1
  profile_id = ibm_iam_trusted_profile.profile.id
  identifier = var.trusted_profile_identity.identifier
  # NOTE: Passing var.trusted_profile_identity.identity_type for both type and identity_type
  # See https://github.com/IBM-Cloud/terraform-provider-ibm/issues/6158
  identity_type = var.trusted_profile_identity.identity_type
  type          = var.trusted_profile_identity.identity_type
  accounts      = var.trusted_profile_identity.identity_type == "user" && contains(keys(var.trusted_profile_identity), "accounts") ? var.trusted_profile_identity.accounts : null
  description   = try(var.trusted_profile_identity.description, null)
}
