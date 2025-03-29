########################################################################################################################
# Outputs
########################################################################################################################

output "enterprise_account_ids" {
  description = "List of child enterprise account IDs"
  value       = data.ibm_enterprise_accounts.all_accounts.accounts[*].id
}

output "trusted_profile_template_id" {
  description = "The ID of the Trusted Profile Template"
  value       = ibm_iam_trusted_profile_template.trusted_profile_template_instance.template_id
}

output "trusted_profile_template_version" {
  description = "The version of the Trusted Profile Template"
  value       = ibm_iam_trusted_profile_template.trusted_profile_template_instance.version
}

output "trusted_profile_template_assignment_ids" {
  description = "The list of assignment IDs to child accounts"
  value       = [for assignment in ibm_iam_trusted_profile_template_assignment.account_settings_template_assignment_instance : assignment.id]
}

