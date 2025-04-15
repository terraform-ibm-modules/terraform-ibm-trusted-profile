########################################################################################################################
# Outputs
########################################################################################################################

output "trusted_profile_template_id" {
  description = "The ID of the trusted profile template"
  value       = split("/", ibm_iam_trusted_profile_template.trusted_profile_template_instance.id)[0]
}

output "enterprise_account_ids" {
  description = "List of child enterprise account IDs"
  value       = data.ibm_enterprise_accounts.all_accounts.accounts[*].id
}

output "trusted_profile_template_id_raw" {
  value = ibm_iam_trusted_profile_template.trusted_profile_template_instance.id
}

output "trusted_profile_template_version" {
  description = "The version of the Trusted Profile Template"
  value       = ibm_iam_trusted_profile_template.trusted_profile_template_instance.version
}

output "trusted_profile_template_assignment_ids" {
  description = "The list of assignment IDs to child accounts"
  value       = split("/", ibm_iam_trusted_profile_template.trusted_profile_template_instance.id)[0]
}

