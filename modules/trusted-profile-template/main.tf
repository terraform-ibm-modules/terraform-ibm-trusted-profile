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

# data "ibm_enterprise_accounts" "all_accounts" {}

# data "ibm_enterprise_account_groups" "all_groups" {
#   depends_on = [data.ibm_enterprise_accounts.all_accounts]
# }

locals {
  # These are the IDs explicitly provided to the module
  explicit_group_ids   = var.account_group_ids_to_assign
  explicit_account_ids = var.account_ids_to_assign

  # Determine if "all" is specified for groups
  # This correctly handles empty lists by making the condition false
  # all_groups_specified = (
  #   length(local.explicit_group_ids) > 0 ? local.explicit_group_ids[0] == "all" ? true : false : false
  # )

  # Determine if "all" is specified for accounts
  # This correctly handles empty lists by making the condition false
  # all_accounts_specified = (
  #   length(local.explicit_account_ids) > 0 ? local.explicit_account_ids[0] == "all" ? true : false : false
  # )

  # Targets for groups:
  # If "all" is specified, use all groups from the data source.
  # Otherwise, if explicit_group_ids is empty, this part of the concat will be an empty list.
  # If explicit_group_ids contains specific IDs, use those.
  # group_targets_for_for_each = local.all_groups_specified ? [
  #   for group in data.ibm_enterprise_account_groups.all_groups.account_groups : {
  #     id   = group.id
  #     type = "AccountGroup"
  #   }
  #   ] : (
  # Only iterate if explicit_group_ids is not empty
  group_targets_for_for_each = (length(local.explicit_group_ids) > 0 ? [
    for id in local.explicit_group_ids : {
      id   = id
      type = "AccountGroup"
    }
    ] : [] # Return an empty list if explicit_group_ids is empty
  )

  # Targets for accounts:
  # If "all" is specified, use all accounts from the data source.
  # Otherwise, if explicit_account_ids is empty, this part of the concat will be an empty list.
  # If explicit_account_ids contains specific IDs, use those.
  # account_targets_for_for_each = local.all_accounts_specified ? [
  #   for account in data.ibm_enterprise_accounts.all_accounts.accounts : {
  #     id   = account.id
  #     type = "Account"
  #   }
  #   ] : (
  # Only iterate if explicit_account_ids is not empty
  account_targets_for_for_each = (length(local.explicit_account_ids) > 0 ? [
    for id in local.explicit_account_ids : {
      id   = id
      type = "Account"
    }
    ] : [] # Return an empty list if explicit_account_ids is empty
  )

  # Combine all targets into a map suitable for for_each.
  # If both `group_targets_for_for_each` and `account_targets_for_for_each` are empty lists,
  # `concat` will produce an empty list, and the `for` loop will produce an empty map,
  # which correctly results in no assignments.
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
