# Enterprise Example for Trusted Profile Module

This example demonstrates how to configure and deploy multiple IBM Cloud IAM Trusted Profiles using the `terraform-ibm-trusted-profile` module. It includes examples for App Configuration and Sysdig Workload Protection (SCC-WP) with associated trust relationships and a reusable IAM template structure.

## Features

- Creates custom IAM roles for profile-template management.
- Deploys 3 trusted profiles:
  - General App Configuration
  - App Configuration with Enterprise-level permissions
  - SCC-WP for App Configuration access
- Sets up trust relationships with App Config and SCC-WP CRNs.
- Defines reusable IAM policy templates and applies them using a trusted profile template.
- Automatically assigns the template to all child accounts or to specific account groups.

## Prerequisites

- App Configuration and SCC-WP instances must exist.
- The CRNs of these services should be passed as variables.

## Usage

```hcl
module "trusted_profile_app_config_general" {
  source                      = "../.."
  trusted_profile_name        = "app-config-general-profile-${var.suffix}"
  trusted_profile_description = "Trusted Profile for App Config general permissions"
  ...
}

module "trusted_profile_template" {
  source              = "../../modules/trusted-profile-template"
  profile_name        = "Trusted Profile for IBM Cloud CSPM in SCC-WP"
  profile_description = "Template profile used to onboard child accounts"
  ...
}
```

## Inputs

| Name                  | Description                                                   | Type    | Default                 |
|-----------------------|---------------------------------------------------------------|---------|-------------------------|
| `suffix`              | Random suffix for naming resources                            | string  | `"basic-trusted-profile"` |
| `region`              | IBM Cloud region                                              | string  | `"eu-de"`               |
| `ibmcloud_api_key`    | IBM Cloud API Key                                             | string  | n/a                     |
| `app_config_crn`      | CRN of the App Configuration instance                         | string  | n/a                     |
| `scc_wp_crn`          | CRN of the SCC-WP instance                                    | string  | n/a                     |
| `onboard_account_groups` | Whether to onboard all enterprise account groups            | bool    | `true`                 |
| `account_group_ids`   | List of specific account group IDs to onboard                 | list    | `[]`                    |

## Notes

- The trusted profile template is assigned by default to all account groups.
- Policy templates for identity and platform services are created and linked dynamically.

---


