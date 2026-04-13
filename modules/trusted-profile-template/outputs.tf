########################################################################################################################
# Outputs
########################################################################################################################

output "trusted_profile_template_id" {
  description = "The ID of the trusted profile template"
  value       = split("/", ibm_iam_trusted_profile_template.trusted_profile_template_instance.id)[0]
}

output "enterprise_account_ids" {
  description = "List of child enterprise account IDs (empty when not using 'all')"
  value       = local.all_accounts || local.all_groups ? data.ibm_enterprise_accounts.all_accounts[0].accounts[*].id : []
}

output "trusted_profile_template_id_raw" {
  description = "Full raw ID (including version) of the trusted profile template"
  value       = ibm_iam_trusted_profile_template.trusted_profile_template_instance.id
}

output "trusted_profile_template_version" {
  description = "The version of the Trusted Profile Template"
  value       = ibm_iam_trusted_profile_template.trusted_profile_template_instance.version
}

output "trusted_profile_template_assignment_ids" {
  description = "The map of assignment IDs for account groups and accounts"
  value = {
    for k, v in ibm_iam_trusted_profile_template_assignment.account_settings_template_assignment_instance : k => v.id
  }
}
