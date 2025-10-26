# Test the actual trusted-profile-template module with dynamic account IDs
# This will demonstrate whether the fix-profile branch resolves the for_each dependency issue

# Use actual IBM data source like the real module does
data "ibm_iam_account_settings" "current" {}

# Create mock account data that includes computed values from the data source
# This more accurately reproduces the for_each dependency issue
locals {
  mock_accounts = [
    {
      id             = data.ibm_iam_account_settings.current.account_id
      name           = "current-account"
      iam_service_id = "ServiceId-${random_id.suffix[0].hex}"
    },
    {
      # This computed key pattern is what causes the original for_each bug
      id             = "${data.ibm_iam_account_settings.current.account_id}-child-${random_id.suffix[1].hex}"
      name           = "mock-child-account"
      iam_service_id = "ServiceId-${random_id.suffix[1].hex}"
    }
  ]
}

resource "random_id" "suffix" {
  count       = 2
  byte_length = 4
}

# Use the actual trusted-profile-template module with dynamic account IDs
# On main branch: this should fail with "Invalid for_each argument"
# On fix-profile branch: this should succeed because of static keys
module "trusted_profile_template" {
  source = "../../modules/trusted-profile-template"

  template_name        = "${var.prefix}-dynamic-test-template"
  template_description = "Template to test for_each dependency fix"
  profile_name         = "${var.prefix}-dynamic-test-profile"
  profile_description  = "Profile to test for_each dependency fix"

  # Pass dynamic account IDs from data source - this is what triggers the original bug
  # The for_each keys will depend on data.ibm_iam_account_settings.current.account_id
  account_ids_to_assign = [
    for account in local.mock_accounts : account.id
  ]

  account_group_ids_to_assign = []

  identities = [
    {
      type       = "serviceid"
      iam_id     = local.mock_accounts[0].iam_service_id
      identifier = replace(local.mock_accounts[0].iam_service_id, "ServiceId-", "")
    }
  ]

  policy_templates = [
    {
      name        = "${var.prefix}-test-policy"
      description = "Test policy for for_each dependency fix"
      roles       = ["Viewer"]
      attributes = [{
        key      = "service_name"
        value    = "iam-identity"
        operator = "stringEquals"
      }]
    }
  ]
}
