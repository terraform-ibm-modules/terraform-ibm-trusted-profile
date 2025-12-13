##############################################################################
# Complete example
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.4.4"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

resource "ibm_is_vpc" "vpc" {
  name = "${var.prefix}-vpc"
}

resource "ibm_is_vpc_address_prefix" "prefix" {
  name = "${var.prefix}-prefix"
  zone = "${var.region}-1"
  vpc  = ibm_is_vpc.vpc.id
  cidr = "10.100.10.0/24"
}

resource "ibm_is_subnet" "subnet" {
  depends_on = [
    ibm_is_vpc_address_prefix.prefix
  ]
  name            = "${var.prefix}-vpc"
  vpc             = ibm_is_vpc.vpc.id
  zone            = "${var.region}-1"
  ipv4_cidr_block = "10.100.10.0/24"
  tags            = var.resource_tags
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
}

resource "ibm_is_ssh_key" "public_key" {
  name       = "${var.prefix}-key"
  public_key = trimspace(tls_private_key.ssh_key.public_key_openssh)
}

data "ibm_is_image" "image" {
  name = "ibm-ubuntu-22-04-3-minimal-amd64-1"
}

resource "ibm_is_instance" "vsi" {
  name    = "${var.prefix}-vsi"
  image   = data.ibm_is_image.image.id
  profile = "bx2-2x8"

  primary_network_interface {
    subnet = ibm_is_subnet.subnet.id
  }

  vpc  = ibm_is_vpc.vpc.id
  zone = "${var.region}-1"
  keys = [ibm_is_ssh_key.public_key.id]
}

locals {
  trusted_profile_name = "${var.prefix}-profile"
}

module "trusted_profile" {
  source                      = "../.."
  trusted_profile_name        = local.trusted_profile_name
  trusted_profile_description = "Example Trusted Profile"

  trusted_profile_policies = [
    # example of policy with Viewer access to the given resource group
    {
      unique_identifier = "${local.trusted_profile_name}-0"
      roles             = ["Viewer"]
      resources = [{
        resource      = module.resource_group.resource_group_id
        resource_type = "resource-group"
      }]
    },
    # example of policy using service_group_id resource attribute
    {
      unique_identifier = "${local.trusted_profile_name}-1"
      roles             = ["Service ID creator", "User API key creator", "Administrator"]
      resource_attributes = [{
        name     = "service_group_id"
        value    = "IAM"
        operator = "stringEquals"
      }]
    },
    # example of policy with Viewer access to the KMS service in the given resource group using rule conditions
    {
      unique_identifier = "${local.trusted_profile_name}-2"
      roles             = ["Viewer"]
      resources = [{
        resource_group_id = module.resource_group.resource_group_id
        service           = "kms"
      }]
      rule_conditions = [
        {
          key      = "{{environment.attributes.day_of_week}}"
          operator = "dayOfWeekAnyOf"
          value    = ["1+00:00", "2+00:00", "3+00:00", "4+00:00"]
        },
        {
          key      = "{{environment.attributes.current_time}}"
          operator = "timeLessThanOrEquals"
          value    = ["17:00:00+00:00"]
        }
      ]
      rule_operator = "or"
      pattern       = "attribute-based-condition:resource:literal-and-wildcard"
    },
    # example of policy for all Identity and Access enabled services using resource_tags
    # NOTE: The code is commented out as it will fail if a policy already exists in an account with the same attributes

    # {
    #   unique_identifier   = "${local.trusted_profile_name}-3"
    #   roles               = ["Viewer"]
    #   description         = "IAM Trusted Profile Policy"
    #   resource_attributes = [{
    #     name              = "serviceType"
    #     value             = "service"
    #     operator          = "stringEquals"
    #   }]
    #   # resource_tags are only allowed in policy with resource attribute serviceType, where value is equal to service
    #   resource_tags = [{
    #     name              = "env"
    #     value             = "dev"
    #   }]
    # }
  ]

  trusted_profile_claim_rules = [{
    unique_identifier = "${local.trusted_profile_name}-0"
    name              = var.prefix
    conditions = [{
      claim    = "Group"
      operator = "CONTAINS"
      value    = "\"Admin\""
    }]

    type    = "Profile-CR"
    cr_type = "VSI"
  }]

  trusted_profile_links = [{
    unique_identifier = "${local.trusted_profile_name}-0"
    name              = var.prefix
    cr_type           = "VSI"
    links = [{
      name = var.prefix
      crn  = ibm_is_instance.vsi.crn
    }]
  }]

  trusted_profile_identity = {
    identifier    = ibm_is_instance.vsi.crn
    identity_type = "crn"
  }
}
