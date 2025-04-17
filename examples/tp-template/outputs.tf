########################################################################################################################
# Outputs
########################################################################################################################

output "all_enterprise_accounts" {
  description = "List of all enterprise accounts returned by the data source"
  value       = module.trusted_profile_template.enterprise_account_ids
}

output "trusted_profile_template_id" {
  description = "ID of the trusted profile template"
  value       = split("/", module.trusted_profile_template.trusted_profile_template_id_raw)[0]
}
