##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.2.1"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Simulate enterprise accounts (for testing dynamic IDs)
##############################################################################

# This simulates the scenario where account IDs come from another resource/module
# and are not known at plan time (similar to module.enterprise.enterprise_accounts_iam_response)
resource "terraform_data" "simulated_enterprise_accounts" {
  count = 2
  
  input = {
    id            = "account-${count.index + 1}-${random_string.account_suffix[count.index].result}"
    iam_service_id = "iam-ServiceId-${random_string.service_id_suffix[count.index].result}"
  }
}

resource "random_string" "account_suffix" {
  count   = 2
  length  = 8
  special = false
  upper   = false
}

resource "random_string" "service_id_suffix" {
  count   = 2
  length  = 32
  special = false
  upper   = false
}

##############################################################################
# Create trusted profile template with dynamic account assignment
##############################################################################

module "trusted_profile_template" {
  source               = "../../modules/trusted-profile-template"
  template_name        = "${var.prefix}-dynamic-assignment-template"
  template_description = "Test template with dynamic account assignment"
  profile_name         = "${var.prefix}-dynamic-profile"
  profile_description  = "Profile for testing dynamic assignment"
  
  # Identities based on simulated service IDs (dynamic)
  identities = [
    for account in terraform_data.simulated_enterprise_accounts : {
      type       = "serviceid"
      iam_id     = account.output.iam_service_id
      identifier = replace(account.output.iam_service_id, "iam-", "")
    }
  ]
  
  # Dynamic account assignment - this should work without "known only after apply" error
  account_ids_to_assign = [
    for account in terraform_data.simulated_enterprise_accounts : account.output.id
  ]
  
  account_group_ids_to_assign = []
  
  policy_templates = [
    {
      name        = "${var.prefix}-iam-admin-access"
      description = "Grants Administrator role to all Identity and Access enabled services (IAM service group)."
      roles       = ["Administrator"]
      attributes = [{
        key      = "service_group_id"
        value    = "IAM"
        operator = "stringEquals"
      }]
    }
  ]
}