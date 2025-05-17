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
  }]
}
