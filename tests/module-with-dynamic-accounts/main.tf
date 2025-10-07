# Test the actual trusted-profile-template module with dynamic account IDs
# This will demonstrate whether the fix-profile branch resolves the for_each dependency issue

# Create dynamic account IDs that are "known only after apply"
resource "terraform_data" "enterprise_accounts" {
  count = 2
  input = {
    id             = "account-${count.index + 1}-${random_id.suffix[count.index].hex}"
    iam_service_id = "ServiceId-${random_id.suffix[count.index].hex}"
  }
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

  # Pass dynamic account IDs - this is what triggers the original bug
  account_ids_to_assign = [
    for account in terraform_data.enterprise_accounts : account.output.id
  ]

  account_group_ids_to_assign = []

  identities = [
    {
      type       = "serviceid"
      iam_id     = terraform_data.enterprise_accounts[0].output.iam_service_id
      identifier = replace(terraform_data.enterprise_accounts[0].output.iam_service_id, "ServiceId-", "")
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
