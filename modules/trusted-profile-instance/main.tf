resource "ibm_iam_trusted_profile_identity" "trust_identity" {
  count         = var.trusted_profile_identity != null ? 1 : 0
  profile_id    = var.profile_id
  identifier    = var.trusted_profile_identity.identifier
  identity_type = var.trusted_profile_identity.identity_type
  type          = var.trusted_profile_identity.type
}

