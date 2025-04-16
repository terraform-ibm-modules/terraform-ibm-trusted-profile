# Identity CRN that will be linked to the trusted profile (e.g., App Config instance CRN)
variable "identity_crn" {
  description = "CRN of the identity to link with the trusted profile (e.g. App Config CRN)"
  type        = string
}

variable "ibmcloud_api_key" {
  description = "IBM Cloud API key"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "Region where resources will be deployed"
  type        = string
  default     = "eu-de"
}

