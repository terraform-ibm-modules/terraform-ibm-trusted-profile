##############################################################################
# Complete example
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.0"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

resource "ibm_is_vpc" "vpc" {
  name = "${var.prefix}-vpc"
}

resource "ibm_is_subnet" "subnet" {
  name            = "${var.prefix}-vpc"
  vpc             = ibm_is_vpc.vpc.id
  zone            = "${var.region}-1"
  ipv4_cidr_block = "10.240.0.0/24"
  tags            = var.resource_tags
}

resource "ibm_is_ssh_key" "public_key" {
  name       = "${var.prefix}-key"
  public_key = var.ssh_key
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
    primary_ip {
      address = "10.240.0.6"
    }
  }

  network_interfaces {
    name   = "eth1"
    subnet = ibm_is_subnet.subnet.id
  }

  vpc  = ibm_is_vpc.vpc.id
  zone = "${var.region}-1"
  keys = [ibm_is_ssh_key.public_key.id]
}

module "trusted_profile" {
  source                      = "../.."
  trusted_profile_name        = "${var.prefix}-profile"
  trusted_profile_description = "Example Trusted Profile"

  trusted_profile_policies = [{
    roles = ["Reader", "Viewer"]
    resources = [{
      resource_group_id = module.resource_group.resource_group_id
      service           = "kms"
    }]
  }]

  trusted_profile_claim_rules = [{
    conditions = [{
      claim    = "Group"
      operator = "CONTAINS"
      value    = "\"Admin\""
    }]

    type    = "Profile-CR"
    cr_type = "VSI"
  }]
  trusted_profile_links = [{
    cr_type = "VSI"
    links = [{
      crn = ibm_is_instance.vsi.crn
    }]
  }]
}
