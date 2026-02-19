variable "project_id" {
  description = "The GCP project ID to apply IAM bindings to"
  type        = string
}

variable "iam_bindings_file" {
  description = "Path to the YAML file containing IAM bindings"
  type        = string
}
