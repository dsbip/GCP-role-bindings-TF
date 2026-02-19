locals {
  iam_data = yamldecode(file(var.iam_bindings_file))

  # Flatten the YAML structure into individual principal-role pairs
  iam_bindings = flatten([
    for entry in local.iam_data.bindings : [
      for role in entry.roles : {
        principal = entry.principal
        role      = role
      }
    ]
  ])
}

resource "google_project_iam_member" "bindings" {
  for_each = {
    for binding in local.iam_bindings :
    "${binding.principal}--${binding.role}" => binding
  }

  project = var.project_id
  role    = each.value.role
  member  = each.value.principal
}
