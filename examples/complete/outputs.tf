##############################################################################
# Outputs
##############################################################################
output "trusted_profile_template_id" {
  description = "The template ID for the trusted profile template"
  value       = module.trusted_profile_template.trusted_profile_template_id
}

output "region" {
  description = "The region all resources were provisioned in"
  value       = var.region
}

output "prefix" {
  description = "The prefix used to name all provisioned resources"
  value       = var.prefix
}

output "resource_group_name" {
  description = "The name of the resource group used"
  value       = var.resource_group
}

output "resource_tags" {
  description = "List of resource tags"
  value       = var.resource_tags
}

output "trusted_profile" {
  description = "The provisioned trusted profile"
  value       = module.trusted_profile
}
