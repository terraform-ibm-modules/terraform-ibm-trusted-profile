module "trusted_profile_template" {
  source = "../../modules/trusted-profile-template"

  template_name        = "minimal-template"
  template_description = "Minimal example for trusted profile template"

  profile_name         = "Minimal Trusted Profile"
  profile_description  = "Used for testing minimal usage"

  identity_crn = var.identity_crn

  onboard_all_account_groups = true

  policy_templates = [
    {
      name        = "minimal-access"
      description = "Basic access to identity services"
      roles       = ["Viewer"]
      service     = "service"  # Use supported keyword
    }
  ]
}

