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

output "trusted_profile_id_app_config_general" {
  value = module.trusted_profile_app_config_general.profile_id
}

output "trusted_profile_id_app_config_enterprise" {
  value = module.trusted_profile_app_config_enterprise.profile_id
}

output "trusted_profile_id_scc_wp" {
  value = module.trusted_profile_scc_wp.profile_id
}


output "trusted_profile_app_config_general" {
  value = module.trusted_profile_app_config_general
}

output "trusted_profile_app_config_enterprise" {
  value = module.trusted_profile_app_config_enterprise
}

output "trusted_profile_scc_wp" {
  value = module.trusted_profile_scc_wp
}

