# Trusted Profile Template Submodule for IBM Cloud IAM

This Terraform submodule provisions a Trusted Profile Template in IBM Cloud IAM. It allows you to define reusable IAM policies and associate them with a trusted profile. The template can be applied across all accounts in an enterprise, simplifying identity and access management at scale.

## Purpose

Use this module to create a trusted profile template and assign it to all enterprise accounts or specific account groups. The module also provisions IAM policy templates that define the roles and services accessible via the trusted profile.

## Features

- Creates IAM policy templates with access roles.
- Defines a Trusted Profile Template with identity linking.
- Assigns the profile template to all child accounts in an enterprise.
- Dynamically references policy templates from the profile template.

## Example Usage

```hcl
module "trusted_profile_template" {
  source              = "../../modules/trusted-profile-template"
  profile_name        = "Trusted Profile for IBM Cloud CSPM in SCC-WP"
  profile_description = "Template profile used to onboard child accounts"
  identity_crn        = var.app_config_crn

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
```

## Inputs

| Name                  | Description                                                     | Type   | Required |
|-----------------------|-----------------------------------------------------------------|--------|----------|
| `profile_name`        | Name of the trusted profile                                     | string | yes      |
| `profile_description` | Description of the trusted profile                              | string | yes      |
| `identity_crn`        | CRN of the identity to bind (e.g. App Config instance)          | string | yes      |
| `policy_templates`    | List of IAM policy templates to define in the template          | list   | yes      |


## Outputs

| Name                               | Description                                          |
|------------------------------------|------------------------------------------------------|
| `enterprise_account_ids`          | List of enterprise child account IDs                |
| `trusted_profile_template_id_raw` | Full ID of the trusted profile template             |
| `trusted_profile_template_version`| Version of the trusted profile template             |
| `trusted_profile_template_assignment_ids` | Assignment target IDs (account group or account) |

## Resources Created

- `ibm_iam_policy_template`
- `ibm_iam_trusted_profile_template`
- `ibm_iam_trusted_profile_template_assignment`

## Notes

- You must have Enterprise account access and valid permissions to use this module.
- Policy templates and trusted profiles must be properly configured to avoid assignment issues.


