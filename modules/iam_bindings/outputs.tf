output "bindings" {
  description = "Map of all project-level IAM bindings that were created"
  value = {
    for key, binding in google_project_iam_member.bindings :
    key => {
      principal = binding.member
      role      = binding.role
      project   = binding.project
    }
  }
}

output "cloud_run_bindings" {
  description = "Map of all Cloud Run service IAM bindings that were created"
  value = {
    for key, binding in google_cloud_run_service_iam_member.bindings :
    key => {
      principal = binding.member
      role      = binding.role
      service   = binding.service
      location  = binding.location
      project   = binding.project
    }
  }
}
