# Enterprise Example: SCC-WP with App Config and Trusted Profiles

> Only supported in an IBM Cloud Enterprise Account.

This example demonstrates how to deploy and configure IAM Trusted Profiles and templates with App Configuration and SCC Workload Protection (SCC-WP).

---

## Components Deployed

- IBM Cloud App Configuration
- IBM Cloud Security and Compliance Center - Workload Protection (SCC-WP)
- Custom IAM Role: `TemplateAssignmentReader`
- Three Trusted Profiles:
  - App Config - General (read access)
  - App Config - Enterprise (template permissions)
  - SCC-WP Profile (access to App Config and enterprise services)
- Trust Relationships (via the `trusted-profile-instance` submodule)
- Trusted Profile Template with policy templates
- Template assignment to all account groups

---

## Trust Link Note

Each trusted profile uses the `trusted_profile_links` block to link to a CRN (App Config or SCC-WP), enabling the identity to assume the trusted profile.

---

```bash
terraform init
terraform apply
```

---

