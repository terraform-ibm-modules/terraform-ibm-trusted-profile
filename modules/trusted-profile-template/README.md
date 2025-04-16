# Trusted Profile Template Submodule for IBM Cloud IAM

This Terraform submodule provisions a Trusted Profile Template in IBM Cloud IAM. It allows you to define reusable IAM policies and associate them with a trusted profile. The template can be applied across all accounts in an enterprise, simplifying identity and access management at scale.

---

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.3.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement_ibm) | >= 1.76.1, < 2.0.0 |

---

## Resources

- `ibm_iam_policy_template`
- `ibm_iam_trusted_profile_template`
- `ibm_iam_trusted_profile_template_assignment`

---

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `template_name` | Name of the trusted profile template | `string` | n/a | yes |
| `template_description` | Description of the trusted profile template | `string` | n/a | yes |
| `profile_name` | Name of the trusted profile inside the template | `string` | n/a | yes |
| `profile_description` | Description of the trusted profile | `string` | `null` | no |
| `identity_crn` | CRN of the identity to bind (e.g., App Config CRN) | `string` | n/a | yes |
| `onboard_account_groups` | Whether to assign to all account groups | `bool` | `false` | no |
| `policy_templates` | List of IAM policy templates to define | `list(object({ name = string, description = string, roles = list(string), service = string }))` | n/a | yes |

---

## Outputs

| Name | Description |
|------|-------------|
| `trusted_profile_template_id` | ID of the created trusted profile template |
| `trusted_profile_template_version` | Version of the created template |
| `trusted_profile_template_assignment_ids` | Assigned target IDs (accounts or groups) |

---

## Example Usage

```hcl
module "trusted_profile_template" {
  source  = "terraform-ibm-modules/trusted-profile/ibm//modules/trusted-profile-template"
  version = "X.Y.Z" # Replace "X.Y.Z" with a release version to lock into a specific release

  template_name          = "Trusted Profile Template for SCC-WP"
  template_description   = "IAM trusted profile template to onboard accounts for CSPM"
  profile_name           = "Trusted Profile for IBM Cloud CSPM in SCC-WP"
  profile_description    = "Template profile used to onboard child accounts"
  identity_crn           = var.app_config_crn
  onboard_account_groups = true

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

