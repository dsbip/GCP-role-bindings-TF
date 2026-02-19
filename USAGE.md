# GCP IAM Role Bindings Terraform Module — Usage Guide

## Overview

This Terraform module binds IAM roles to principals (users, service accounts, groups) in a Google Cloud project. Bindings are defined in a YAML file and the module applies them using `google_project_iam_member` resources.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.0
- A GCP project with billing enabled
- Authenticated `gcloud` CLI (`gcloud auth application-default login`) or a service account key
- The caller must have the **`roles/resourcemanager.projectIamAdmin`** role (or equivalent) on the target project

## YAML File Format

Create a YAML file with an array of bindings. Each entry needs a `principal` and a list of `roles`:

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

| Name       | Description                                       |
|------------|---------------------------------------------------|
| `bindings` | Map of all IAM bindings created (principal, role, project) |

## Full Example

See the [examples/](examples/) directory for a ready-to-use configuration:

```bash
cd examples/
terraform init
terraform plan -var="project_id=my-gcp-project-id"
terraform apply -var="project_id=my-gcp-project-id"
```

## Important Notes

- This module uses **`google_project_iam_member`** (additive). It will **not** remove existing bindings that are not in the YAML file.
- To remove a binding, delete it from the YAML file and run `terraform apply` — Terraform will destroy the corresponding resource.
- Duplicate principal–role pairs in the YAML will cause a Terraform key conflict error. Ensure each combination is unique.
