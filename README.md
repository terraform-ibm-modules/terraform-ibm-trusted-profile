<!-- Update the title -->
# Terraform IBM Trusted Profile

[![Stable (With quality checks)](https://img.shields.io/badge/Status-Stable%20(With%20quality%20checks)-green)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-trusted-profile?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-trusted-profile/releases/latest)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)

<!-- Add a description of module(s) in this repo -->
This module creates a trusted profile, a set of policies given to the profile, a set of claim rules for the profile, and a set of infrastructure links to the profile.

<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGIN OVERVIEW HOOK -->
## Overview
* [terraform-ibm-trusted-profile](#terraform-ibm-trusted-profile)
* [Examples](./examples)
    * [Basic example](./examples/basic)
    * [Complete example](./examples/complete)
* [Contributing](#contributing)
<!-- END OVERVIEW HOOK -->


<!--
If this repo contains any reference architectures, uncomment the heading below and links to them.
(Usually in the `/reference-architectures` directory.)
See "Reference architecture" in Authoring Guidelines in the public documentation at
https://terraform-ibm-modules.github.io/documentation/#/implementation-guidelines?id=reference-architecture
-->
<!-- ## Reference architectures -->


<!-- This heading should always match the name of the root level module (aka the repo name) -->
## terraform-ibm-trusted-profile

### Usage

```hcl
module "trusted_profile {
  source                      = "terraform-ibm-modules/trusted-profile/ibm"
  version                     = "X.X.X" # Replace "X.X.X" with a release version to lock into a specific release
  trusted_profile_name        = "example-profile"
  trusted_profile_description = "Example Trusted Profile"

  trusted_profile_policies = [{
    roles = ["Reader", "Viewer"]
    resources = [{
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
      crn = ibm_is_instance.vsi.crn # Existing Infrastructure CRN
    }]
  }]
}
```

#### Using the variables

The 3 variables `trusted_profile_policies`, `trusted_profile_claim_rules`, and `trusted_profile_links` are lists of objects whose fields are mapped out to match the arguments for the provider, for more information on the variables visit the following provider documentation:

* [trusted_profile_policies](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_trusted_profile_policy)
* [trusted_profile_claim_rules](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_trusted_profile_claim_rule)
* [trusted_profile_links](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_trusted_profile_link)

### Required IAM access policies

You need the following permissions to run this module.

- Account Management
    - **IAM Identity** service
        - `Administrator` platform access

You will also need `Administrator` access for any service which you are creating a policy for in the trusted profile. Lastly, your account must have authentication from an external identity provider enabled; see [this documentation](https://cloud.ibm.com/docs/account?topic=account-idp-integration) for more information.

<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.53.0, < 2.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_iam_trusted_profile.profile](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_trusted_profile) | resource |
| [ibm_iam_trusted_profile_claim_rule.claim_rule](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_trusted_profile_claim_rule) | resource |
| [ibm_iam_trusted_profile_link.link](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_trusted_profile_link) | resource |
| [ibm_iam_trusted_profile_policy.policy](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_trusted_profile_policy) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_trusted_profile_claim_rules"></a> [trusted\_profile\_claim\_rules](#input\_trusted\_profile\_claim\_rules) | A list of Trusted Profile Claim Rule objects that are applied to the Trusted Profile created by the module. | <pre>list(object({<br/>    # required arguments<br/>    conditions = list(object({<br/>      claim    = string<br/>      operator = string<br/>      value    = string<br/>    }))<br/><br/>    type = string<br/><br/>    # optional arguments<br/>    cr_type    = optional(string)<br/>    expiration = optional(number)<br/>    name       = optional(string)<br/>    realm_name = optional(string)<br/>  }))</pre> | `null` | no |
| <a name="input_trusted_profile_description"></a> [trusted\_profile\_description](#input\_trusted\_profile\_description) | Description of the trusted profile. | `string` | `null` | no |
| <a name="input_trusted_profile_links"></a> [trusted\_profile\_links](#input\_trusted\_profile\_links) | A list of Trusted Profile Link objects that are applied to the Trusted Profile created by the module. | <pre>list(object({<br/>    # required arguments<br/>    cr_type = string<br/>    links = list(object({<br/>      crn       = string<br/>      namespace = optional(string)<br/>      name      = optional(string)<br/>    }))<br/><br/>    # optional arguments<br/>    name = optional(string)<br/>  }))</pre> | `null` | no |
| <a name="input_trusted_profile_name"></a> [trusted\_profile\_name](#input\_trusted\_profile\_name) | Name of the trusted profile. | `string` | n/a | yes |
| <a name="input_trusted_profile_policies"></a> [trusted\_profile\_policies](#input\_trusted\_profile\_policies) | A list of Trusted Profile Policy objects that are applied to the Trusted Profile created by the module. | <pre>list(object({<br/>    roles              = list(string)<br/>    account_management = optional(bool)<br/>    description        = optional(string)<br/><br/>    resources = optional(list(object({<br/>      service              = optional(string)<br/>      service_type         = optional(string)<br/>      resource_instance_id = optional(string)<br/>      region               = optional(string)<br/>      resource_type        = optional(string)<br/>      resource             = optional(string)<br/>      resource_group_id    = optional(string)<br/>      service_group_id     = optional(string)<br/>      attributes           = optional(map(any))<br/>    })), null)<br/><br/>    resource_attributes = optional(list(object({<br/>      name     = string<br/>      value    = string<br/>      operator = optional(string)<br/>    })))<br/><br/>    resource_tags = optional(list(object({<br/>      name     = string<br/>      value    = string<br/>      operator = optional(string)<br/>    })))<br/><br/>    rule_conditions = optional(list(object({<br/>      key      = string<br/>      operator = string<br/>      value    = list(any)<br/>    })))<br/><br/>    rule_operator = optional(string)<br/>    pattern       = optional(string)<br/>  }))</pre> | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_trusted_profile"></a> [trusted\_profile](#output\_trusted\_profile) | Output of the Trusted Profile |
| <a name="output_trusted_profile_claim_rules"></a> [trusted\_profile\_claim\_rules](#output\_trusted\_profile\_claim\_rules) | Output of the Trusted Profile Claim Rules |
| <a name="output_trusted_profile_links"></a> [trusted\_profile\_links](#output\_trusted\_profile\_links) | Output of the Trusted Profile Links |
| <a name="output_trusted_profile_policies"></a> [trusted\_profile\_policies](#output\_trusted\_profile\_policies) | Output of the Trusted Profile Policies |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
