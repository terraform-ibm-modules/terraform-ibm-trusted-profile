resource "ibm_iam_policy_template" "profile_template_policies" {
  for_each = {
    for pt in var.policy_templates :
    pt.name => pt
  }

  name = each.value.name
  committed = true

  policy {
    type        = "access"
    description = each.value.description

    resource {
      attributes {
        key     = "serviceType"
        value    = each.value.service
        operator = "stringEquals"
      }
    }

    roles = each.value.roles
  }
}

resource "ibm_iam_trusted_profile_template" "trusted_profile_template_instance" {
    name        = var.profile_name
    description = var.profile_description

  profile {
    name        = var.profile_name
    description = var.profile_description
    identities {
      type       = "crn"
      iam_id     = var.identity_crn
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

data "ibm_iam_account_settings" "iam_account_settings" {}

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
  for_each = local.combined_targets

  template_id      = split("/", ibm_iam_trusted_profile_template.trusted_profile_template_instance.id)[0]
  template_version = ibm_iam_trusted_profile_template.trusted_profile_template_instance.version
  target           = each.value.id
  target_type      = each.value.type

  provisioner "local-exec" {
    command = "echo Assigned template to ${each.value.type}: ${each.value.id}"
  }
}

