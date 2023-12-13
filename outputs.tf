########################################################################################################################
# Outputs
########################################################################################################################

output "trusted_profile" {
  description = "Output of the Trusted Profile"
  value       = ibm_iam_trusted_profile.profile
}

output "trusted_profile_policies" {
  description = "Output of the Trusted Profile Policies"
  value       = ibm_iam_trusted_profile_policy.policy[*]
}

output "trusted_profile_claim_rules" {
  description = "Output of the Trusted Profile Claim Rules"
  value       = ibm_iam_trusted_profile_claim_rule.claim_rule[*]
}

output "trusted_profile_links" {
  description = "Output of the Trusted Profile Links"
  value       = ibm_iam_trusted_profile_link.link[*]
}
