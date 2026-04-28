# GCP IAM Role Bindings Terraform Module

## What this is

A Terraform module that manages GCP IAM role bindings from a YAML configuration file. Supports both project-level bindings and resource-level bindings (Cloud Run services).

## Project structure

- `modules/iam_bindings/` — The reusable Terraform module
- `examples/` — Working example with sample YAML and Terraform config
- `USAGE.md` — End-user documentation
- `LEARNINGS.md` — Notes from local testing

## How to test

```bash
cd examples/
terraform init
terraform validate
terraform plan -var="project_id=test-project"
```

`terraform plan` works without GCP credentials for dry-run validation.

## Key design decisions

- Uses `google_project_iam_member` (additive) instead of authoritative resources to avoid clobbering existing bindings.
- Uses `google_cloud_run_service_iam_member` for Cloud Run resource-level bindings.
- YAML is parsed with `yamldecode(file(...))` — no external dependencies.
- `cloud_run_bindings` section is optional via `try(..., [])` for backward compatibility.
- `for_each` keys use `--` separator for readability in state (e.g., `principal--role`).
