# Learnings from Local Testing

## Test Environment

- **Terraform version**: v1.2.7 (windows_386)
- **Google provider**: hashicorp/google v7.20.0
- **OS**: Windows 11

## Test Results

### `terraform init` — PASSED
- Module source resolution from relative path (`../modules/iam_bindings`) works correctly.
- Google provider v7.20.0 was auto-selected to satisfy the `>= 4.0` constraint.

### `terraform validate` — PASSED
- All HCL syntax is valid.
- The `yamldecode(file(...))` expression is accepted at validation time.
- Variable references within the module resolve correctly.

### `terraform plan` — PASSED (dry-run, no credentials applied)
- Terraform successfully parsed the YAML file and produced **5 planned resources**, matching the 5 unique principal–role pairs in `iam_bindings.yaml`.
- Each `google_project_iam_member` resource is keyed as `"<principal>--<role>"`, which ensures uniqueness and produces readable state keys.
- Outputs correctly display the planned bindings map.

## Key Learnings

1. **`yamldecode` + `file()` works natively** — No external data sources or provisioners needed. Terraform's built-in `yamldecode()` handles the YAML parsing, and `file()` reads relative to the calling module's path.

2. **`flatten()` is essential for nested loops** — The YAML has a one-to-many relationship (one principal → many roles). Using `flatten()` around a nested `for` expression collapses it into a flat list suitable for `for_each`.

3. **`for_each` requires a map or set of strings** — The flattened list of objects must be converted to a map via a `for` expression with a unique key (`"${principal}--${role}"`). Using a list directly with `for_each` is not allowed.

4. **`google_project_iam_member` is additive** — Unlike `google_project_iam_binding` (which is authoritative per role) or `google_project_iam_policy` (which is authoritative for the entire project), `iam_member` only adds the specified binding without affecting existing ones. This is the safest choice for incremental role management.

5. **`terraform plan` works without credentials** — For validation and dry-run testing, `terraform plan` generates a valid execution plan even without GCP authentication. It only fails at `apply` time when it needs to make API calls.

6. **Terraform v1.2.7 compatibility** — Despite being an older version, all features used (`yamldecode`, `flatten`, `for_each` with complex keys) are fully supported. The module does not rely on any features introduced after v1.0.

7. **Duplicate key protection** — If the same principal–role pair appears twice in the YAML, Terraform will throw a `for_each` duplicate key error at plan time, preventing accidental duplicates before any infrastructure changes are made.
