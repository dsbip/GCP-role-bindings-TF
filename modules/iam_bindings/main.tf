locals {
  iam_data = yamldecode(file(var.iam_bindings_file))

  iam_bindings = flatten([
    for entry in local.iam_data.bindings : [
      for role in entry.roles : {
        principal = entry.principal
        role      = role
      }
    ]
  ])

  cloud_run_bindings = flatten([
    for entry in try(local.iam_data.cloud_run_bindings, []) : [
      for pair in setproduct(entry.principals, entry.roles) : {
        service   = entry.service
        location  = entry.location
        principal = pair[0]
        role      = pair[1]
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

resource "google_cloud_run_service_iam_member" "bindings" {
  for_each = {
    for binding in local.cloud_run_bindings :
    "${binding.service}--${binding.location}--${binding.principal}--${binding.role}" => binding
  }

  project  = var.project_id
  location = each.value.location
  service  = each.value.service
  role     = each.value.role
  member   = each.value.principal
}
