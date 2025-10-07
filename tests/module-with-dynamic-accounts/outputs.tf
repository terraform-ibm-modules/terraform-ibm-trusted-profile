output "template_assignment_ids" {
  value       = module.trusted_profile_template.trusted_profile_template_assignment_ids
  description = "Template assignment IDs from the module"
}

output "dynamic_account_ids" {
  value = [
    for account in terraform_data.enterprise_accounts : account.output.id
  ]
  description = "The dynamic account IDs used in the test"
}
