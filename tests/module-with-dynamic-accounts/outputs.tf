output "template_assignment_ids" {
  value       = module.trusted_profile_template.trusted_profile_template_assignment_ids
  description = "Template assignment IDs from the module"
}

output "dynamic_account_ids" {
  value = [
    for account in local.mock_accounts : account.id
  ]
  description = "The dynamic account IDs used in the test (based on current account)"
}

output "current_account_id" {
  value       = data.ibm_iam_account_settings.current.account_id
  description = "The current IBM Cloud account ID from data source"
}
