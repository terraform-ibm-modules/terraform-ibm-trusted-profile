# Trusted Profile Template Submodule for IBM Cloud IAM

This Terraform submodule provisions a Trusted Profile Template in IBM Cloud IAM. It allows you to define reusable IAM policies and associate them with a trusted profile. The template can be applied across all accounts in an enterprise, simplifying identity and access management at scale.

### Usage

```hcl
module "trusted_profile_template" {
  source  = "terraform-ibm-modules/trusted-profile/ibm//modules/trusted-profile-template"
  version = "X.Y.Z" # Replace "X.Y.Z" with a release version to lock into a specific release

  template_name          = "Trusted Profile Template example"
  template_description   = "IAM trusted profile template example"
  profile_name           = "Trusted Profile example"
  profile_description    = "Template profile example"
  identity_crn           = "crn........"

  policy_templates = [
    {
      name        = "identity-access"
      description = "Policy template for identity services"
      roles       = ["Viewer", "Reader"]
      attributes = [{
        key      = "serviceName"
        value    = "cloud-object-storage"
        operator = "stringEquals"
        },
        {
          key      = "serviceInstance"
          value    = "xxxXXXxxxXXXxxxXXX"
          operator = "stringEquals"
      }]
    },
    {
      name        = "platform-access"
      description = "Policy template for platform services"
      roles       = ["Viewer", "Service Configuration Reader"]
      attributes  = [{
        key      = "serviceType"
        value    = "platform_service"
        operator = "stringEquals"
      }]
    }
  ]
}
```

### Required IAM access policies

You need the following permissions to run this module.

- Service
    - **Enterprise** service
        - `Administrator` platform access
    - **IAM Identity** service
        - `Administrator` platform access

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.76.1, < 2.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_iam_policy_template.profile_template_policies](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_policy_template) | resource |
| [ibm_iam_trusted_profile_template.trusted_profile_template_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_trusted_profile_template) | resource |
| [ibm_iam_trusted_profile_template_assignment.account_settings_template_assignment_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_trusted_profile_template_assignment) | resource |
| [terraform_data.iam_policy_template_replacement](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_group_ids_to_assign"></a> [account\_group\_ids\_to\_assign](#input\_account\_group\_ids\_to\_assign) | A list of account group IDs to assign the template to. Support passing the string 'all' in the list to assign to all account groups. | `list(string)` | <pre>[<br/>  "all"<br/>]</pre> | no |
| <a name="input_account_ids_to_assign"></a> [account\_ids\_to\_assign](#input\_account\_ids\_to\_assign) | A list of account IDs to assign the template to. Support passing the string 'all' in the list to assign to all accounts. | `list(string)` | `[]` | no |
| <a name="input_identities"></a> [identities](#input\_identities) | List of identity blocks with type, iam\_id, and identifier | <pre>list(object({<br/>    type       = string<br/>    iam_id     = string<br/>    identifier = string<br/>  }))</pre> | `[]` | no |
| <a name="input_policy_templates"></a> [policy\_templates](#input\_policy\_templates) | List of IAM policy templates to create | <pre>list(object({<br/>    name        = string<br/>    description = string<br/>    roles       = list(string)<br/>    attributes = list(object({<br/>      key      = string<br/>      value    = string<br/>      operator = string<br/>    }))<br/>  }))</pre> | n/a | yes |
| <a name="input_profile_description"></a> [profile\_description](#input\_profile\_description) | Description of the trusted profile inside the template | `string` | `null` | no |
| <a name="input_profile_name"></a> [profile\_name](#input\_profile\_name) | Name of the trusted profile inside the template | `string` | n/a | yes |
| <a name="input_template_description"></a> [template\_description](#input\_template\_description) | Description of the trusted profile template | `string` | `null` | no |
| <a name="input_template_name"></a> [template\_name](#input\_template\_name) | Name of the trusted profile template | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_enterprise_account_ids"></a> [enterprise\_account\_ids](#output\_enterprise\_account\_ids) | List of child enterprise account IDs |
| <a name="output_trusted_profile_template_assignment_ids"></a> [trusted\_profile\_template\_assignment\_ids](#output\_trusted\_profile\_template\_assignment\_ids) | The list of assignment IDs to child accounts |
| <a name="output_trusted_profile_template_id"></a> [trusted\_profile\_template\_id](#output\_trusted\_profile\_template\_id) | The ID of the trusted profile template |
| <a name="output_trusted_profile_template_id_raw"></a> [trusted\_profile\_template\_id\_raw](#output\_trusted\_profile\_template\_id\_raw) | Full raw ID (including version) of the trusted profile template |
| <a name="output_trusted_profile_template_version"></a> [trusted\_profile\_template\_version](#output\_trusted\_profile\_template\_version) | The version of the Trusted Profile Template |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
