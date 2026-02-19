output "bindings" {
  description = "Map of all IAM bindings that were created"
  value = {
    for key, binding in google_project_iam_member.bindings :
    key => {
      principal = binding.member
      role      = binding.role
      project   = binding.project
    }
  }
}
