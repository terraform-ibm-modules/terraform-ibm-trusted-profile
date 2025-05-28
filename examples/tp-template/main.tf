##############################################################################
# Create trusted profile template
##############################################################################

module "trusted_profile_template" {
  source               = "../../modules/trusted-profile-template"
  template_name        = "${var.prefix}-template"
  template_description = "Minimal example for trusted profile template"
  profile_name         = "${var.prefix}-profile"
  profile_description  = "Sample description"
  identity_crn         = "crn:v1:bluemix:public:cloud-object-storage:global:a/888877776665655554444e3333d22221:cosInstanceId::"
  policy_templates = [
    {
      name        = "${var.prefix}-cos-reader-access"
      description = "COS reader access"
      roles       = ["Reader"]
      attributes = [{
        key      = "serviceName"
        value    = "cloud-object-storage"
        operator = "stringEquals"
        }
      ]
    }
  ]
  account_group_ids_to_assign = var.account_group_ids_to_assign
}
