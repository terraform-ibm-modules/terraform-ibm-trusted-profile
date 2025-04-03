resource "ibm_iam_policy_template" "profile_template_policy_all_identity" {
  name        = "${var.prefix}01-all-identity-policy-template01-${var.suffix}"
  policy {
    type        = "access"
    description = "Unique IAM access template ${var.suffix} testing rj"
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
  name        = "${var.prefix}01-all-management-policy-template-01-${var.suffix}"
  policy {
    type        = "access"
    description = "01testing for all management - ${var.suffix}"
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

data "ibm_enterprise_accounts" "all_accounts" {}

data "ibm_iam_account_settings" "iam_account_settings" {}

resource "ibm_iam_trusted_profile_template_assignment" "account_settings_template_assignment_instance" {
  for_each         = {
    for account in data.ibm_enterprise_accounts.all_accounts.accounts :
    account.id => account if account.id != data.ibm_iam_account_settings.iam_account_settings.account_id
  }

  template_id      = split("/", ibm_iam_trusted_profile_template.trusted_profile_template_instance.id)[0]
  template_version = ibm_iam_trusted_profile_template.trusted_profile_template_instance.version
  target           = each.value.id
  target_type      = "Account"
}

