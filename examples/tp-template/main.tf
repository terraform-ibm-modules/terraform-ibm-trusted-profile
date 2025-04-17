##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.2.0"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# COS
##############################################################################

module "cos" {
  source            = "terraform-ibm-modules/cos/ibm"
  version           = "8.21.8"
  resource_group_id = module.resource_group.resource_group_id
  cos_instance_name = "${var.prefix}-cos"
  cos_tags          = var.resource_tags
  create_cos_bucket = false
}

##############################################################################
# Create trusted profile template
##############################################################################

module "trusted_profile_template" {
  source               = "../../modules/trusted-profile-template"
  template_name        = "${var.prefix}-template"
  template_description = "Minimal example for trusted profile template"
  profile_name         = "${var.prefix}-profile"
  profile_description  = "Sample description"
  identity_crn         = module.cos.cos_instance_crn
  policy_templates = [
    {
      name        = "${var.prefix}-cos-reader-access"
      description = "COS reader access"
      roles       = ["Reader"]
      service     = "service"
    }
  ]
  onboard_all_account_groups = false # Set this to true to add the template to all account groups. Support for selecting specific groups is coming in https://github.com/terraform-ibm-modules/terraform-ibm-trusted-profile/issues/163
}
