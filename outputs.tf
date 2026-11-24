########################################################################################################################
# Outputs
########################################################################################################################

output "profile_id" {
  description = "ID of the trusted profile"
  value       = ibm_iam_trusted_profile.profile.profile_id
}

output "trusted_profile" {
  description = "Output of the Trusted Profile"
  value       = ibm_iam_trusted_profile.profile
}

output "trusted_profile_policies" {
  description = "Output of the Trusted Profile Policies"
  # Select attributes individually: referencing the whole resource object reads the deprecated `profile_id`
  # and makes Terraform emit a 'Deprecated value used' warning.
  value = {
    for k, p in ibm_iam_trusted_profile_policy.policy : k => {
      id                  = p.id
      iam_id              = p.iam_id
      roles               = p.roles
      description         = p.description
      account_management  = p.account_management
      pattern             = p.pattern
      rule_operator       = p.rule_operator
      tags                = p.tags
      transaction_id      = p.transaction_id
      resources           = p.resources
      resource_attributes = p.resource_attributes
      resource_tags       = p.resource_tags
      rule_conditions     = p.rule_conditions
    }
  }
}

output "trusted_profile_claim_rules" {
  description = "Output of the Trusted Profile Claim Rules"
  value       = ibm_iam_trusted_profile_claim_rule.claim_rule[*]
}

output "trusted_profile_links" {
  description = "Output of the Trusted Profile Links"
  value       = ibm_iam_trusted_profile_link.link[*]
}
