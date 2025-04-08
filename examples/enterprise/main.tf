# Output block to show all enterprise account IDs from the template module
output "all_enterprise_accounts" {
  value = module.trusted_profile_template.enterprise_account_ids
}

# Generates a random suffix to ensure unique resource names
resource "random_id" "suffix" {
  byte_length = 4
}

# Creates a timestamp used for naming
locals {
  timestamp = formatdate("YYYYMMDDhhmmss", timestamp())
}


# Trusted Profile for general App Config permissions
module "trusted_profile_app_config_general" {
  source                         = "../.."
  trusted_profile_name           = "app-config-general-profile-${var.suffix}"
  trusted_profile_description    = "Trusted Profile for App Config general permissions"

  # Policies include Viewer and Reader access on services
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

  # Trust link with App Config CRN
  trusted_profile_links = [{
    cr_type = "VSI"
    links = [{
      crn = var.app_config_crn
    }]
  }]
}



# Trusted Profile for App Config enterprise-level permissions
module "trusted_profile_app_config_enterprise" {
  source                         = "../.."
  trusted_profile_name           = "app-config-enterprise-profile-${var.suffix}"
  trusted_profile_description    = "Trusted Profile for App Config to manage IAM templates"

  # Uses a custom role and Viewer for IAM permissions
  trusted_profile_policies = [
    {
      roles = ["Viewer", "Template Assignment Reader"]
      resource_attributes = [{
        name     = "service_group_id"
        value    = "IAM"
        operator = "stringEquals"
      }]
      description = "All IAM Account Management services - using custom role"
    },
    {
      roles = ["Viewer"]
      resources = [{
        service = "enterprise"
      }]
      description = "Enterprise access"
    }
  ]

  # Trust link with App Config CRN
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
  trusted_profile_description    = "Trusted Profile for SCC-WP to interact with App Config"

  # Grants access to App Config and Enterprise services
  trusted_profile_policies = [
    {
      roles = ["Viewer", "Service Configuration Reader", "Manager"]
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

  # Trust link with SCC-WP CRN
  trusted_profile_links = [{
    cr_type = "VSI"
    links = [{
      crn = var.scc_wp_crn
    }]
  }]
}


module "trust_relationship_app_config_general" {
  source                    = "../../modules/trusted-profile-instance"
  profile_id                = module.trusted_profile_app_config_general.profile_id
  trusted_profile_identity  = {
    identifier    = var.app_config_crn
    identity_type = "crn"
    type          = "crn"
  }
}

module "trust_relationship_app_config_enterprise" {
  source                    = "../../modules/trusted-profile-instance"
  profile_id                = module.trusted_profile_app_config_enterprise.profile_id
  trusted_profile_identity  = {
    identifier    = var.app_config_crn
    identity_type = "crn"
    type          = "crn"
  }
}

module "trust_relationship_scc_wp" {
  source                    = "../../modules/trusted-profile-instance"
  profile_id                = module.trusted_profile_scc_wp.profile_id
  trusted_profile_identity  = {
    identifier    = var.scc_wp_crn
    identity_type = "crn"
    type          = "crn"
  }
}



module "trusted_profile_template" {
  source              = "../../modules/trusted-profile-template"
  prefix              = "app-config"
  suffix              = "${random_id.suffix.hex}-${local.timestamp}"
  profile_name        = "Trusted Profile for IBM Cloud CSPM in SCC-WP"
  profile_description = "Template profile used to onboard child accounts"
  identity_crn        = var.app_config_crn
  ibmcloud_api_key    = var.ibmcloud_api_key
  region              = var.region
  onboard_account_groups = var.onboard_account_groups
  account_group_ids      = var.account_group_ids

  policy_templates = [
    {
      name        = "identity-access"
      description = "Policy template for identity services"
      roles       = ["Viewer", "Reader"]
      service     = "service"
    },
    {
      name        = "platform-access"
      description = "Policy template for platform services"
      roles       = ["Viewer", "Service Configuration Reader"]
      service     = "platform_service"
    }
  ]
}

