variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Token"
  sensitive   = true
}

variable "prefix" {
  type        = string
  description = "Prefix name for all related resources"
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources"
  default     = []
}

variable "resource_group" {
  type        = string
  description = "An existing resource group name to use for this example, if unset a new resource group will be created"
  default     = null
}

variable "account_group_ids_to_assign" {
  type        = list(string)
  default     = ["all"]
  description = "A list of account group IDs to assign the template to. Support passing the string 'all' in the list to assign to all account groups."
  nullable    = false
}
