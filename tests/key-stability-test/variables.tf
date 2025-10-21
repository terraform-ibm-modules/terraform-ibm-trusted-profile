variable "prefix" {
  type        = string
  description = "Prefix for test resources"
}

variable "ibmcloud_api_key" {
  type        = string
  description = "IBM Cloud API key for authentication"
  sensitive   = true
}

variable "account_group_ids_to_assign" {
  type        = list(string)
  description = "List of account group IDs to test key stability"
  default     = []
}

variable "account_ids_to_assign" {
  type        = list(string)
  description = "List of account IDs to test key stability"
  default     = []
}
