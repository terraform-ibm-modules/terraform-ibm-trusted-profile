variable "profile_id" {
  type        = string
  description = "ID du trusted profile cible"
}

variable "trusted_profile_identity" {
  type = object({
    identifier    = string
    identity_type = string
    type          = string
  })
  default     = null
  description = "Confiance (identity) à lier au trusted profile"
}

