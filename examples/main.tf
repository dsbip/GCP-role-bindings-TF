provider "google" {
  project = var.project_id
  region  = var.region
}

module "iam_bindings" {
  source = "../modules/iam_bindings"

  project_id        = var.project_id
  iam_bindings_file = "${path.module}/iam_bindings.yaml"
}
