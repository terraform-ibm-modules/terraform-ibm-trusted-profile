##############################################################################
# Outputs
##############################################################################

output "trusted_profile_template_id" {
  description = "The ID of the trusted profile template"
  value       = module.trusted_profile_template.trusted_profile_template_id
}

output "simulated_account_ids" {
  description = "The dynamically generated account IDs used for assignment"
  value       = [for account in terraform_data.simulated_enterprise_accounts : account.output.id]
}

output "template_assignment_ids" {
  description = "The assignment IDs for the template"
  value       = module.trusted_profile_template.trusted_profile_template_assignment_ids
}