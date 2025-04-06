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






# Local variables for targeting only Account Groups
locals {
  # Retrieve all enterprise account groups
  group_targets = [
    for group in data.ibm_enterprise_account_groups.all_groups.account_groups : {
      id   = group.id
      type = "AccountGroup"
    }
  ]

  # Prepare a map for Terraform's for_each using group id and type
  combined_targets = {
    for target in local.group_targets :
    "${target.type}-${target.id}" => target
  }
}

# Resource to assign the IAM trusted profile template to Account Groups only
resource "ibm_iam_trusted_profile_template_assignment" "account_settings_template_assignment_instance" {
  for_each = local.combined_targets

  template_id      = split("/", ibm_iam_trusted_profile_template.trusted_profile_template_instance.id)[0]
  template_version = ibm_iam_trusted_profile_template.trusted_profile_template_instance.version
  target           = each.value.id
  target_type      = each.value.type

  # Optional: Log success with local-exec (for visibility)
  provisioner "local-exec" {
    command = "echo ✅ Assigned template to ${each.value.type}: ${each.value.id}"
  }
}

