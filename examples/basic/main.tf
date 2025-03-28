output "all_enterprise_accounts" {
  value = module.trusted_profile_template.enterprise_account_ids
}

resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  timestamp = formatdate("YYYYMMDDhhmmss", timestamp())
}

provider "ibm" {
  region           = "us-south"
  ibmcloud_api_key = var.ibmcloud_api_key
}

module "trusted_profile_app_config_general" {
  source                         = "../.."
  trusted_profile_name           = "app-config-general-profile-${var.suffix}"
  trusted_profile_description    = "Trusted Profile for App Config general permissions"

  trusted_profile_policies = [
    {
      roles              = ["Viewer", "Service Configuration Reader"]
      account_management = true
      description        = "All Account Management Services"
    },
    {
      roles = ["Viewer", "Service Configuration Reader", "Reader"]
      resource_attributes = [{
        name     = "serviceType"
        value    = "service"
        operator = "stringEquals"
      }]
      description = "All Identity and Access enabled services"
    }
  ]

  trusted_profile_links = [{
    cr_type = "VSI"
    links = [{
      crn = var.app_config_crn
    }]
  }]
}

module "trusted_profile_app_config_enterprise" {
  source                         = "../.."
  trusted_profile_name           = "app-config-enterprise-profile-${var.suffix}"
  trusted_profile_description    = "Trusted Profile for App Config to manage IAM templates"

  trusted_profile_policies = [
    {
      roles = ["Viewer",  "Template Assignment Reader"]
      resource_attributes = [{
        name     = "service_group_id"
        value    = "IAM"
        operator = "stringEquals"
      }]
      description = "All IAM Account Management services using custom role - testing by rj"
    },
    {
      roles = ["Viewer"]
      resources = [{
        service = "enterprise"
      }]
      description = "Enterprise access"
    }
  ]

  trusted_profile_links = [{
    cr_type = "VSI"
    links = [{
      crn = var.app_config_crn
    }]
  }]
}

module "trusted_profile_scc_wp" {
  source                         = "../.."
  trusted_profile_name           = "scc-wp-profile-${var.suffix}"
  trusted_profile_description    = "Trusted Profile for SCC-WP to interact with App Config testing by rj"

  trusted_profile_policies = [
    {
      roles = ["Viewer", "Service Configuration Reader"]
      resources = [{
        service = "apprapp"
      }]
      description = "App Config access"
    },
    {
      roles = ["Viewer", "Usage Report Viewer"]
      resources = [{
        service = "enterprise"
      }]
      description = "Enterprise access"
    }
  ]

  trusted_profile_links = [{
    cr_type = "VSI"
    links = [{
      crn = var.scc_wp_crn
    }]
  }]
}

module "trusted_profile_template" {
  source              = "../../modules/trusted-profile-template"
  prefix              = "app-config"
  suffix              = "${random_id.suffix.hex}-${local.timestamp}"
  profile_name        = "Trusted Profile for IBM Cloud CSPM in SCC-WP testingrj"
  profile_description = "Template profile used to onboard child accounts testingrj"
  identity_crn        = var.app_config_crn
  ibmcloud_api_key    = var.ibmcloud_api_key
  region              = var.region
}

