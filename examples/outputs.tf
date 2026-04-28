output "iam_bindings" {
  description = "All project-level IAM bindings created by the module"
  value       = module.iam_bindings.bindings
}

output "cloud_run_bindings" {
  description = "All Cloud Run service IAM bindings created by the module"
  value       = module.iam_bindings.cloud_run_bindings
}
