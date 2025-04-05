resource "ibm_iam_policy_template" "profile_template_policy_all_identity" {
  name        = "${var.prefix}01-all-identity-policy-template01-${var.suffix}"
  policy {
    type        = "access"
    description = "IAM access template ${var.suffix} "
    resource {
      attributes {
        key      = "serviceType"
        operator = "stringEquals"
        value    = "service"
      }
    }
    roles     = ["Viewer", "Service Configuration Reader", "Reader"]
  }
  committed = true
}

resource "ibm_iam_policy_template" "profile_template_policy_all_management" {
  name        = "${var.prefix}all-management-policy-template${var.suffix}"
  policy {
    type        = "access"
    description = "Policy template for all management - ${var.suffix}"
    resource {
      attributes {
        key      = "serviceType"
        operator = "stringEquals"
        value    = "platform_service"
      }
    }
    roles     = ["Viewer", "Service Configuration Reader"]
  }
  committed = true
}

resource "ibm_iam_trusted_profile_template" "trusted_profile_template_instance" {
  name        = "${var.prefix}-trusted-profile-template"
  description = "${var.prefix}-trusted-profile-template"
  profile {
    name        = var.profile_name
    description = var.profile_description
    identities {
      type       = "crn"
      iam_id     = var.identity_crn
      identifier = var.identity_crn
    }
  }

  policy_template_references {
    id      = ibm_iam_policy_template.profile_template_policy_all_identity.template_id
    version = ibm_iam_policy_template.profile_template_policy_all_identity.version
  }

  policy_template_references {
    id      = ibm_iam_policy_template.profile_template_policy_all_management.template_id
    version = ibm_iam_policy_template.profile_template_policy_all_management.version
  }

  committed = true
}

data "ibm_iam_account_settings" "iam_account_settings" {}

data "ibm_enterprise_accounts" "all_accounts" {}

data "ibm_enterprise_account_groups" "all_groups" {
  depends_on = [data.ibm_enterprise_accounts.all_accounts]
}


locals {
  group_targets = var.onboard_account_groups ? [
    for group in data.ibm_enterprise_account_groups.all_groups.account_groups : {
      id   = group.id
      type = "AccountGroup"
    }
  ] : [
    for group_id in var.account_group_ids : {
      id   = group_id
      type = "AccountGroup"
    }
  ]

  account_targets = var.onboard_account_groups ? [] : [
    for account in data.ibm_enterprise_accounts.all_accounts.accounts : {
      id   = account.id
      type = "Account"
    } if account.id != data.ibm_iam_account_settings.iam_account_settings.account_id
  ]

  combined_targets = {
    for target in concat(local.account_targets, local.group_targets) :
    "${target.type}-${target.id}" => target
  }
}




resource "ibm_iam_trusted_profile_template_assignment" "account_settings_template_assignment_instance" {
  for_each         = local.combined_targets

  template_id      = split("/", ibm_iam_trusted_profile_template.trusted_profile_template_instance.id)[0]
  template_version = ibm_iam_trusted_profile_template.trusted_profile_template_instance.version
  target           = each.value.id
  target_type      = each.value.type


  lifecycle {
    ignore_changes = [template_version]
  }
}

