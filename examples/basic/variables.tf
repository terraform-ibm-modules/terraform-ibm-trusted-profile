########################################################################################################################
# Input variables
########################################################################################################################
variable "create_policy_templates" {
  type        = bool
  description = "Whether to create new policy templates. Set to false if they already exist."
  default     = true
}
variable "suffix" {
  type        = string
  description = "Suffix to append to all resources created by this example"
  default     = "basic-trusted-profile"
}

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Key"
  sensitive   = true
}

variable "region" {
  type        = string
  description = "Region to provision all resources created by this example"
  default     = "eu-de"
}

variable "prefix" {
  type        = string
  description = "Prefix to append to all resources created by this example"
  default     = "basic-trusted-profile"
}

variable "app_config_crn" {
  type        = string
  description = "CRN of the App Configuration instance"
}

variable "scc_wp_crn" {
  type        = string
  description = "CRN of the SCC Workload Protection instance"
}
