########################################################################################################################
# Trusted Profile
########################################################################################################################

module "trusted_profile" {
  source               = "../.."
  trusted_profile_name = "${var.prefix}-profile"
  trusted_profile_policies = [{
    roles              = ["Viewer"]
    account_management = true
  }]
  trusted_profile_claim_rules = [{
    type = "Profile-CR"
    conditions = [{
      claim    = "Groups"
      operator = "CONTAINS"
      value    = "\"Admin\""
    }]
    name    = "rule-1"
    cr_type = "IKS_SA"
  }]
}
