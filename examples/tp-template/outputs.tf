########################################################################################################################
# Outputs
########################################################################################################################

output "all_enterprise_accounts" {
  description = "List of all enterprise accounts returned by the data source"
  value       = module.trusted_profile_template.enterprise_account_ids
}

output "trusted_profile_template_id" {
  description = "ID of the trusted profile template"
  value       = module.trusted_profile_template.trusted_profile_template_id
}

output "trusted_profile_template_id_raw" {
  description = "Full raw ID (including version) of the account settings template"
  value       = module.trusted_profile_template.trusted_profile_template_id_raw
}

output "trusted_profile_template_version" {
  description = "The version of the account settings Template"
  value       = module.trusted_profile_template.trusted_profile_template_version
}

output "trusted_profile_template_assignment_ids" {
  description = "List of assignment IDs to child accounts"
  value       = module.trusted_profile_template.trusted_profile_template_assignment_ids
}
