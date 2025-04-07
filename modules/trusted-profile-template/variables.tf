variable "onboard_account_groups" {
  type        = bool
  default     = true
  description = "Whether to onboard all account groups to the template."
}

variable "account_group_ids" {
  type        = list(string)
  default     = []
  description = "List of account group IDs to assign if onboarding is enabled."
}

variable "prefix" {
  description = "Prefix for naming the templates"
  type        = string
}
variable "suffix" {
  type        = string
  description = "Suffix to ensure unique naming of trusted profile templates and resources"
}
variable "profile_name" {
  description = "Name of the trusted profile inside the template"
  type        = string
}

variable "profile_description" {
  description = "Description of the trusted profile inside the template"
  type        = string
}

variable "identity_crn" {
  description = "CRN of the identity (App Config for example)"
  type        = string
}
variable "ibmcloud_api_key" {
  type        = string
  description = "IBM Cloud API key"
  sensitive   = true
}

variable "region" {
  type        = string
  description = "Region for resource provisioning"
}

