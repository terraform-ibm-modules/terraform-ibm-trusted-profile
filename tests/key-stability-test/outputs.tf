output "assignment_keys" {
  value       = keys(module.trusted_profile_template.trusted_profile_template_assignment_ids)
  description = "The keys used for trusted profile template assignments - validates stable key generation"
}

output "template_id" {
  value       = module.trusted_profile_template.trusted_profile_template_id
  description = "The ID of the created trusted profile template"
}

output "test_account_groups" {
  value       = var.account_group_ids_to_assign
  description = "The account group IDs used in this test"
}

output "test_accounts" {
  value       = var.account_ids_to_assign
  description = "The account IDs used in this test"
}
