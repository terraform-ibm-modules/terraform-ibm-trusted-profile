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
  # Need to force re-create here since a template policy cannot be updated in place (See https://github.com/IBM-Cloud/terraform-provider-ibm/issues/6213#issuecomment-3179425899)
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

  # Need to force re-create here since a trusted profile template cannot be updated in place (See https://github.com/IBM-Cloud/terraform-provider-ibm/issues/6214#issuecomment-3246040100)
  lifecycle {
    replace_triggered_by = [terraform_data.iam_policy_template_replacement]
  }
}

# Check for "all" - only when length is exactly 1 AND value is literally "all"
# Note: If the list contains a single computed value, length==1 is true but we can still
# check if it's the static string "all". Computed values are never equal to "all".
locals {
  all_groups   = length(var.account_group_ids_to_assign) == 1 ? var.account_group_ids_to_assign[0] == "all" : false
  all_accounts = length(var.account_ids_to_assign) == 1 ? var.account_ids_to_assign[0] == "all" : false
}

# Enterprise data sources - only needed when "all" is specified
data "ibm_enterprise_accounts" "all_accounts" {
  count = local.all_accounts || local.all_groups ? 1 : 0
}

data "ibm_enterprise_account_groups" "all_groups" {
  count = local.all_groups ? 1 : 0
}

locals {
  # Build targets using index-based keys for specific IDs (fixes for_each with computed values)
  group_targets = local.all_groups ? {
    for group in data.ibm_enterprise_account_groups.all_groups[0].account_groups :
    "AccountGroup-${group.id}" => { id = group.id, type = "AccountGroup" }
    } : {
    for idx, id in var.account_group_ids_to_assign :
    "AccountGroup-${idx}" => { id = id, type = "AccountGroup" }
  }

  account_targets = local.all_accounts ? {
    for account in data.ibm_enterprise_accounts.all_accounts[0].accounts :
    "Account-${account.id}" => { id = account.id, type = "Account" }
    } : {
    for idx, id in var.account_ids_to_assign :
    "Account-${idx}" => { id = id, type = "Account" }
  }

  combined_targets = merge(local.group_targets, local.account_targets)
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

  # temp workaround for https://github.com/IBM-Cloud/terraform-provider-ibm/issues/6216
  lifecycle {
    ignore_changes = [resources]
  }
}
