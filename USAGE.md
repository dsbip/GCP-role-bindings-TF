# GCP IAM Role Bindings Terraform Module — Usage Guide

## Overview

This Terraform module binds IAM roles to principals (users, service accounts, groups) in Google Cloud. It supports both **project-level** bindings and **resource-level** bindings (Cloud Run services). All bindings are defined in a single YAML file.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.0
- A GCP project with billing enabled
- Authenticated `gcloud` CLI (`gcloud auth application-default login`) or a service account key
- The caller must have the **`roles/resourcemanager.projectIamAdmin`** role (or equivalent) on the target project

## YAML File Format

Create a YAML file with bindings. The file supports two top-level sections:

### Project-level bindings

Each entry needs a `principal` and a list of `roles`:

```yaml
bindings:
  - principal: "user:alice@example.com"
    roles:
      - "roles/viewer"
      - "roles/storage.objectViewer"

  - principal: "serviceAccount:my-sa@my-project.iam.gserviceaccount.com"
    roles:
      - "roles/editor"

  - principal: "group:devs@example.com"
    roles:
      - "roles/compute.admin"
      - "roles/container.developer"
```

### Cloud Run service bindings

Each entry needs a `service` name, `location`, `principal`, and a list of `roles`:

```yaml
cloud_run_bindings:
  - service: "my-api-service"
    location: "us-central1"
    principal: "allUsers"
    roles:
      - "roles/run.invoker"

  - service: "internal-service"
    location: "us-central1"
    principal: "serviceAccount:my-sa@my-project.iam.gserviceaccount.com"
    roles:
      - "roles/run.invoker"
      - "roles/run.viewer"
```

The `cloud_run_bindings` section is optional — omit it if you only need project-level bindings.

### Supported principal types

| Prefix              | Example                                              |
|---------------------|------------------------------------------------------|
| `user:`             | `user:alice@example.com`                             |
| `serviceAccount:`   | `serviceAccount:sa@project.iam.gserviceaccount.com`  |
| `group:`            | `group:devs@example.com`                             |
| `domain:`           | `domain:example.com`                                 |

## Module Usage

### 1. Reference the module

```hcl
module "iam_bindings" {
  source = "./modules/iam_bindings"   # or a remote source

  project_id        = "my-gcp-project-id"
  iam_bindings_file = "${path.module}/iam_bindings.yaml"
}
```

### 2. Configure the provider

```hcl
provider "google" {
  project = "my-gcp-project-id"
  region  = "us-central1"
}
```

### 3. Run Terraform

```bash
terraform init
terraform plan
terraform apply
```

## Module Inputs

| Name                | Type   | Required | Description                                  |
|---------------------|--------|----------|----------------------------------------------|
| `project_id`        | string | yes      | GCP project ID to apply IAM bindings to      |
| `iam_bindings_file` | string | yes      | Path to the YAML file containing IAM bindings |

## Module Outputs

| Name                 | Description                                                        |
|----------------------|--------------------------------------------------------------------|
| `bindings`           | Map of all project-level IAM bindings (principal, role, project)   |
| `cloud_run_bindings` | Map of all Cloud Run service IAM bindings (principal, role, service, location, project) |

## Full Example

See the [examples/](examples/) directory for a ready-to-use configuration:

```bash
cd examples/
terraform init
terraform plan -var="project_id=my-gcp-project-id"
terraform apply -var="project_id=my-gcp-project-id"
```

## Important Notes

- This module uses **additive** IAM resources (`google_project_iam_member`, `google_cloud_run_service_iam_member`). It will **not** remove existing bindings that are not in the YAML file.
- To remove a binding, delete it from the YAML file and run `terraform apply` — Terraform will destroy the corresponding resource.
- Duplicate principal–role pairs in the YAML will cause a Terraform key conflict error. Ensure each combination is unique.
- For Cloud Run bindings, the service must already exist — Terraform will fail at apply time if the service is not found.
- The caller needs **`roles/run.admin`** (or equivalent) on the target Cloud Run services to manage their IAM bindings.
