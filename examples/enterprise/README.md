# Minimal Example for Trusted Profile Template

This example demonstrates how to use the `trusted-profile-template` submodule to create an IBM Cloud IAM Trusted Profile Template with one policy.

---

## Features

- Creates a reusable IAM Trusted Profile Template
- Includes a single trusted profile
- Grants a basic Viewer role
- Automatically assigns the template to all enterprise account groups

---

## Prerequisites

- Enterprise account in IBM Cloud
- A valid CRN for the identity that will assume the trusted profile (e.g., App Config or service ID)

---

## Usage

```bash
terraform init
terraform apply

