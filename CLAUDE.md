# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A published Terraform module — `ZouzIO/attribute-sensor/azurerm` on the Terraform Registry — that provisions the Azure side of the Attribute Sensor. Consumers reference it by version, so changes to the root module's public surface (variables, outputs) are API changes for downstream users.

## Architecture

The root module does two things on `apply`:

1. **Provisions Azure resources** — resource group, a user-assigned managed identity, optionally a storage account + container, optionally a Cost Management export (`azapi_resource.export` using `Microsoft.CostManagement/exports@2023-07-01-preview` because the `azurerm` provider doesn't cover it), and role assignments (`Monitoring Reader` on the subscription, `Storage Blob Data Reader` on the storage account).
2. **Registers the deployment with Attribute** — `data "http" "attribute_registration"` POSTs the resulting identity/storage details to `https://sensor.app.attrb.io/api/v1/azure`. This call has `depends_on` on the role assignments / federated credential / export so it only runs after Azure-side wiring is complete. The registration is part of the module's contract; treat it like a real resource even though it's an `http` data source.

The managed identity is wired to Attribute's GCP service account via a **federated identity credential** with a hard-coded Google subject (`108313149922577077162`, issuer `https://accounts.google.com`). That's how Attribute's backend impersonates the identity to read Azure data — don't change it without coordinating with the backend.

`create_costs_export = false` short-circuits a chain: storage account, container, blob-data-reader role assignment, the `azapi` export, and three fields in the registration POST all disappear. When editing, keep these in sync — every `count = var.create_costs_export ? 1 : 0` resource has matching conditionals in `registration.tf` and `outputs.tf`.

`blob_storage_allowlist = true` flips the storage account to deny-by-default and allows two hardcoded IPs (`35.224.163.103`, `34.41.229.120`) — Attribute's GCP egress. It also flips the export to `SystemAssigned` identity so the export job can write through the firewall.

`var.billing_account_id` overrides the export's `parent_id` (see `locals.export_scope`). The variable name is historical — it accepts any scope Cost Management exports support (billing account, management group, etc.) and is not validated. Default is the provider's subscription.

`var.scope_wide_registration` (default `false`) flips the module into management-group-wide mode. When on:
- `local.management_group_name` is parsed out of `billing_account_id` via regex on `/providers/Microsoft.Management/managementGroups/(.+)$` — bad input fails a precondition on `data.azurerm_management_group.this`.
- `azurerm_role_assignment.subscription.scope` moves from the provider sub to `billing_account_id` so the role inherits to every child subscription.
- `data.azurerm_subscription.registration` iterates over `data.azurerm_management_group.this[0].all_subscription_ids` (recursive — includes nested MGs) to fetch each sub's `tenant_id` / `display_name`.
- `data.http.attribute_registration` is `for_each` over those subscriptions; cost-export fields are merged in only for the iteration whose key equals `data.azurerm_subscription.this.subscription_id` (the provider sub — the only one with an actual export).
- A precondition on `azurerm_role_assignment.subscription` requires the provider sub to be a member of the MG. The single managed identity / storage account / export still live in the provider sub.

## Submodule: `modules/databricks-integration`

Standalone module (separate provider requirement: `databricks/databricks ~> 1.0`). Creates a Databricks service principal bound to the root module's managed identity, grants it `USE_CATALOG`/`USE_SCHEMA`/`SELECT` on `system.billing.usage`, and registers the workspace via a different endpoint: `https://sensor.app.attrb.io/api/v1/azure/databricks`. The `compute` variable supports either `SQL` (lookup via `databricks_sql_warehouse`) or `Cluster` (lookup via `databricks_cluster`); `locals.databricks_sql_endpoint` builds the correct JDBC path for each.

## Common commands

```powershell
terraform fmt -recursive          # run before committing
terraform init                    # in repo root or examples/simple
terraform validate
terraform plan
pre-commit run --all-files        # runs terraform-docs on root + examples/simple
terraform-docs .                  # regenerate README inputs/outputs table manually
```

To test changes locally, use `examples/simple` (it references the root via `source = "../.."`). It requires `organization_id` and `token` as inputs and uses an `azurerm` backend — supply backend config via `terraform init -backend-config=...`.

## Conventions

- **Don't hand-edit the `<!-- BEGIN_TF_DOCS -->` / `<!-- END_TF_DOCS -->` block in `README.md`** — terraform-docs (configured in `.terraform-docs.yml`, mode `inject`) regenerates it. Edit prose outside the markers, then run terraform-docs / pre-commit.
- `moved` blocks in `moved.tf` migrate prior unindexed resources to `[0]` after introducing `count`. Preserve these when refactoring — removing them breaks upgrades for existing users.
- Tag merging: every resource pulls tags via `local.<resource>_tags = merge(try(var.resource_tags["<key>"], {}), var.general_tags)`. New tagged resources should follow that pattern and add a matching `local`.
- The module publishes telemetry through `modtm_module_source` (Azure's standard module-usage telemetry). The version/source are also included in the registration POST.
