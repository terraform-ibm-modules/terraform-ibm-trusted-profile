resource "ibm_iam_policy_template" "profile_template_policies" {
  for_each = {
    for pt in var.policy_templates :
    pt.name => pt
  }

  name      = each.value.name
  committed = true

  policy {
    type        = "access"
    description = each.value.description

    resource {
      attributes {
        key      = "serviceType"
        value    = each.value.service
        operator = "stringEquals"
      }
    }

    roles = each.value.roles
  }
}

resource "ibm_iam_trusted_profile_template" "trusted_profile_template_instance" {
  name        = var.template_name
  description = var.template_description

  profile {
    name        = var.profile_name
    description = var.profile_description
    # TODO: Add support to trusted profile template for user and serviceid types
    # https://github.com/terraform-ibm-modules/terraform-ibm-trusted-profile/issues/165
    identities {
      type       = "crn"
      iam_id     = "crn-${var.identity_crn}" # From IAM team -> ibmid of crn is composed with prefix crn and crn of an resource.
      identifier = var.identity_crn
    }
  }

  dynamic "policy_template_references" {
    for_each = ibm_iam_policy_template.profile_template_policies

    content {
      id      = policy_template_references.value.template_id
      version = policy_template_references.value.version
    }
  }

  committed = true
}

data "ibm_enterprise_accounts" "all_accounts" {}

data "ibm_enterprise_account_groups" "all_groups" {
  depends_on = [data.ibm_enterprise_accounts.all_accounts]
}

locals {
  group_targets = [
    for group in data.ibm_enterprise_account_groups.all_groups.account_groups : {
      id   = group.id
      type = "AccountGroup"
    }
  ]

  combined_targets = {
    for target in local.group_targets :
    "${target.type}-${target.id}" => target
  }
}

resource "ibm_iam_trusted_profile_template_assignment" "account_settings_template_assignment_instance" {
  for_each = var.onboard_all_account_groups ? local.combined_targets : {}

  template_id      = split("/", ibm_iam_trusted_profile_template.trusted_profile_template_instance.id)[0]
  template_version = ibm_iam_trusted_profile_template.trusted_profile_template_instance.version
  target           = each.value.id
  target_type      = each.value.type

  provisioner "local-exec" {
    command = "echo Assigned template to ${each.value.type}: ${each.value.id}"
  }
}
