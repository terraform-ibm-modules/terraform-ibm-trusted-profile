########################################################################################################################
# Provider config
########################################################################################################################

variable "ibmcloud_api_key" {
  type        = string
  sensitive   = true
  description = "IBM Cloud API key"
}

variable "region" {
  type        = string
  default     = "us-east"
  description = "Region for IBM Cloud resources"
}

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}

