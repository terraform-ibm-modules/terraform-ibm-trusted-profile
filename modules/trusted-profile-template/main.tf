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
      dynamic "attributes" {
        for_each = each.value.attributes
        content {
          key      = attributes.value.key
          value    = attributes.value.value
          operator = attributes.value.operator
        }
      }
    }
    # TODO support tags (https://github.com/terraform-ibm-modules/terraform-ibm-trusted-profile/issues/164)
    roles = each.value.roles
  }
  # Temp workaround for https://github.com/IBM-Cloud/terraform-provider-ibm/issues/6213
  lifecycle {
    replace_triggered_by = [terraform_data.iam_policy_template_replacement]
  }
}

resource "terraform_data" "iam_policy_template_replacement" {
  input = var.policy_templates
}

resource "ibm_iam_trusted_profile_template" "trusted_profile_template_instance" {
  name        = var.template_name
  description = var.template_description

  profile {
    name        = var.profile_name
    description = var.profile_description

    dynamic "identities" {
      for_each = var.identities
      content {
        type       = identities.value.type
        iam_id     = identities.value.iam_id
        identifier = identities.value.identifier
      }
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

  # Temp workaround for https://github.com/IBM-Cloud/terraform-provider-ibm/issues/6214
  lifecycle {
    replace_triggered_by = [terraform_data.iam_policy_template_replacement]
  }
}

data "ibm_enterprise_accounts" "all_accounts" {}

data "ibm_enterprise_account_groups" "all_groups" {
  depends_on = [data.ibm_enterprise_accounts.all_accounts]
}

locals {
  #  These are the IDs explicitly provided to the module
  explicit_group_ids   = var.account_group_ids_to_assign
  explicit_account_ids = var.account_ids_to_assign

  #  Determine if "all" is specified for groups
  all_groups_specified = length(local.explicit_group_ids) > 0 && local.explicit_group_ids[0] == "all"

  #  Determine if "all" is specified for accounts
  all_accounts_specified = length(local.explicit_account_ids) > 0 && local.explicit_account_ids[0] == "all"

  #  Targets for groups: either all groups from data source or explicit ones
  group_targets_for_for_each = local.all_groups_specified ? [
    for group in data.ibm_enterprise_account_groups.all_groups.account_groups : {
      id   = group.id
      type = "AccountGroup"
    }
    ] : [
    for id in local.explicit_group_ids : {
      id   = id
      type = "AccountGroup"
    }
  ]

  #  Targets for accounts: either all accounts from data source or explicit ones
  account_targets_for_for_each = local.all_accounts_specified ? [
    for account in data.ibm_enterprise_accounts.all_accounts.accounts : {
      id   = account.id
      type = "Account"
    }
    ] : [
    for id in local.explicit_account_ids : {
      id   = id
      type = "Account"
    }
  ]

  #  Combine all targets into a map suitable for for_each
  combined_targets = {
    for target in concat(local.group_targets_for_for_each, local.account_targets_for_for_each) :
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
