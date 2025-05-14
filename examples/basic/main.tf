########################################################################################################################
# Trusted Profile
########################################################################################################################

module "trusted_profile" {
  source               = "../.."
  trusted_profile_name = "${var.prefix}-profile"
  trusted_profile_policies = [{
    name               = "Viewer-policy"
    roles              = ["Viewer"]
    account_management = true
  }]
}
