########################################################################################################################
# Outputs
########################################################################################################################
# Output block to show all enterprise account IDs from the template module
output "all_enterprise_accounts" {
  value = module.trusted_profile_template.enterprise_account_ids
}

output "trusted_profile_template_id" {
  value = split("/", module.trusted_profile_template.trusted_profile_template_id_raw)[0]
}


