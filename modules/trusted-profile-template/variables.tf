variable "prefix" {
  description = "Prefix for naming the templates"
  type        = string
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

