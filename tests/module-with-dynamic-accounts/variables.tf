variable "prefix" {
  type        = string
  description = "Prefix for test resources"
  default     = "tp-module-test"
}

variable "ibmcloud_api_key" {
  type        = string
  description = "IBM Cloud API key for authentication"
  sensitive   = true
}
