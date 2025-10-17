# Test the trusted-profile-template module for resource key stability
# This test validates that reordering account/group lists doesn't cause resource recreation

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Test the actual trusted-profile-template module for key stability
module "trusted_profile_template" {
  source = "../../modules/trusted-profile-template"

  template_name        = "${var.prefix}-key-test-template"
  template_description = "Template to test resource key stability"
  profile_name         = "${var.prefix}-key-test-profile"
  profile_description  = "Profile to test resource key stability"

  # Test with specific account and group IDs to validate key generation
  account_group_ids_to_assign = var.account_group_ids_to_assign
  account_ids_to_assign       = var.account_ids_to_assign

  policy_templates = [
    {
      name        = "${var.prefix}-key-test-policy"
      description = "Test policy for key stability validation"
      roles       = ["Viewer"]
      attributes = [{
        key      = "serviceName"
        value    = "iam-identity"
        operator = "stringEquals"
      }]
    }
  ]
}