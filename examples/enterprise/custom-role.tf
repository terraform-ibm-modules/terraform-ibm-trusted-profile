resource "ibm_iam_custom_role" "template_assignment_reader" {
  name         = "TemplateAssignmentReader"
  service      = "iam-identity"
  display_name = "Template Assignment Reader"
  description  = "Custom role to allow reading template assignments"
  actions      = ["iam-identity.profile-assignment.read"]
}

