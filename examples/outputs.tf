output "iam_bindings" {
  description = "All IAM bindings created by the module"
  value       = module.iam_bindings.bindings
}
