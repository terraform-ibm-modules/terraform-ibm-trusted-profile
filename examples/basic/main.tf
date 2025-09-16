########################################################################################################################
# Trusted Profile
########################################################################################################################

module "trusted_profile" {
  source               = "../.."
  trusted_profile_name = "${var.prefix}-profile"
  trusted_profile_policies = [{
    unique_identifier  = "account-management-viewer"
    roles              = ["Viewer"]
    account_management = true
    },
    {
      unique_identifier = "region-scoped-viewer"
      roles             = ["Viewer"]
      resources = [{
        # Random service to test region-scoping policy
        service = "cloudantnosqldb"
        region  = var.region
      }]
  }]
}
