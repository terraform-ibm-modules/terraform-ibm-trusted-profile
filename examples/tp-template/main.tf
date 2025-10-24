##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.4.0"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# COS
##############################################################################

module "cos" {
  source            = "terraform-ibm-modules/cos/ibm"
  version           = "10.5.1"
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
  identities = [
    {
      type       = "crn"
      iam_id     = "crn-${module.cos.cos_instance_crn}"
      identifier = module.cos.cos_instance_crn
    }
  ]
  policy_templates = [
    {
      name        = "${var.prefix}-cos-reader-access"
      description = "COS reader access"
      roles       = ["Reader"]
      attributes = [{
        key      = "serviceName"
        value    = "cloud-object-storage"
        operator = "stringEquals"
        },
        {
          key      = "serviceInstance"
          value    = module.cos.cos_instance_guid
          operator = "stringEquals"
      }]
    }
  ]
  account_group_ids_to_assign = var.account_group_ids_to_assign
  account_ids_to_assign       = []
}
