# terraform-azure-attribute-sensor
The module provisions all required infrastracture resources for the Attribute Sensor to operate. Please, refer to the [Inputs](#inputs) section for the configuration options.
## Resources created
The module creates the following resources:
- Resource group
- Managed Identity
- Storage Account to store the Billing Export data (__optional, can be disabled via input variable__)
- Billing Data Export (__optional, can be disabled via input variable__)

## Required permissions
In order to use this module, the user/service principal must have the following permissions:
- `Microsoft.Resources/subscriptions/resourceGroups/read`
- `Microsoft.Resources/subscriptions/resourceGroups/write`
- `Microsoft.Resources/subscriptions/read`
- `Microsoft.Storage/storageAccounts/read`
- `Microsoft.Storage/storageAccounts/write`
- `Microsoft.Storage/storageAccounts/listkeys/action`
- `Microsoft.Storage/storageAccounts/blobServices/containers/read`
- `Microsoft.Storage/storageAccounts/blobServices/containers/write`
- `Microsoft.Storage/storageAccounts/blobServices/read`
- `Microsoft.Storage/storageAccounts/fileServices/read`
- `Microsoft.ManagedIdentity/userAssignedIdentities/read`
- `Microsoft.ManagedIdentity/userAssignedIdentities/write`
- `Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials/read`
- `Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials/write`
- `Microsoft.Authorization/roleAssignments/read`
- `Microsoft.Authorization/roleAssignments/write`
- `Microsoft.CostManagement/exports/read`
- `Microsoft.CostManagement/exports/write`

When `scope_wide_registration = true`, the deploying principal additionally needs the following at **each management group listed in `management_group_ids`**:
- `Microsoft.Management/managementGroups/read` — used by the `azurerm_management_group` data source to enumerate child subscriptions.
- `Microsoft.Resources/subscriptions/read` on every child subscription — used by the per-subscription `azurerm_subscription` data sources to resolve each subscription's tenant ID and display name. Granting `Reader` at MG scope is the simplest way to satisfy this (it inherits to all child subs).
- `Microsoft.Authorization/roleAssignments/write` plus the right to delegate the `Monitoring Reader` role — one assignment is created per listed management group instead of at subscription scope. The built-in `User Access Administrator` role satisfies both the action and the delegation check.

The Cost Management Export and storage resources stay anchored at the provider's default subscription even in management-group-wide mode, so the existing `Microsoft.CostManagement/exports/write` permission listed above (at the subscription scope) is sufficient — no MG-scoped export permission is needed.

The following custom role can be used to assign the required permissions:
```hcl
resource "azurerm_role_definition" "attribute_sensor_terraform" {
  name        = "AttributeSensorTerraform"
  scope       = "/subscriptions/<YOUR_SUBSCRIPTION_ID>"
  description = "Custom role for deploying attribute-sensor module and related resources"

  permissions {
    actions = [
      # Resource Group
      "Microsoft.Resources/subscriptions/resourceGroups/read",
      "Microsoft.Resources/subscriptions/resourceGroups/write",

      # Subscription Read
      "Microsoft.Resources/subscriptions/read",

      # Storage
      "Microsoft.Storage/storageAccounts/read",
      "Microsoft.Storage/storageAccounts/write",
      "Microsoft.Storage/storageAccounts/listkeys/action",
      "Microsoft.Storage/storageAccounts/blobServices/containers/read",
      "Microsoft.Storage/storageAccounts/blobServices/containers/write",
      "Microsoft.Storage/storageAccounts/blobServices/read",
      "Microsoft.Storage/storageAccounts/fileServices/read",

      # Managed Identity + Federated Credential
      "Microsoft.ManagedIdentity/userAssignedIdentities/read",
      "Microsoft.ManagedIdentity/userAssignedIdentities/write",
      "Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials/read",
      "Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials/write",

      # Role Assignments
      "Microsoft.Authorization/roleAssignments/read",
      "Microsoft.Authorization/roleAssignments/write",

      # Cost Management Export
      "Microsoft.CostManagement/exports/read",
      "Microsoft.CostManagement/exports/write",
    ]
    not_actions = []
  }

  assignable_scopes = [
    "/subscriptions/<YOUR_SUBSCRIPTION_ID>",
  ]
}
```
## Overriding the Cost Management Export scope
By default, the Cost Management Export is created at the subscription scope. To attach the export to a different scope (e.g. a Billing Account or a Management Group), set `billing_account_id` to that scope's resource ID. The variable name is historical — it now accepts any Cost Management scope identifier and is used as the export's `parent_id`.

Billing Account scope (format: `/providers/Microsoft.Billing/billingAccounts/{billingAccountId}`):

```hcl
module "attribute-sensor" {
  source  = "ZouzIO/attribute-sensor/azurerm"
  version = "~> 2"

  organization_id = var.organization_id
  token           = var.token

  billing_account_id = "/providers/Microsoft.Billing/billingAccounts/0000000-0000-0000-0000-000000000000:00000002-0002-0002-0002-000000000000_2019-05-31"
}
```

## Skipping the Billing Export creation
If you want to skip the creation of the Billing Export and associated resources (e.g. while having a billing account-scoped Billing Export), you can set the `create_costs_export` input variable to `false`, i.e.:
```hcl
module "attribute-sensor" {
  source  = "ZouzIO/attribute-sensor/azurerm"
  version = "~> 2"

  organization_id     = var.organization_id
  token               = var.token

  create_costs_export = false
}
```
In that case, only the Resource Group and Managed Identity will be created, skipping the Storage Account and Billing Export creation.
## Registering all subscriptions under a management group
By default the module registers only the provider's default subscription with Attribute and creates the `Monitoring Reader` role assignment at that subscription's scope. Setting `scope_wide_registration = true` switches the module to a management-group-wide mode driven by the `management_group_ids` list input:

- A `Monitoring Reader` role assignment is created at **each** management group listed in `management_group_ids`, so it inherits down to every child subscription of every listed MG.
- The module enumerates every subscription under each listed management group recursively (via the `all_subscription_ids` attribute of `azurerm_management_group`, which includes subscriptions in nested management groups), deduplicates the union, and POSTs a registration to Attribute for each one.
- Cost Management Export fields (`storage_container`, `storage_dir`, `storage_account_url`) are sent **only** in the registration for the provider's default subscription — that is the only subscription where the storage account and export resources are actually created.
- `billing_account_id` is independent from `management_group_ids` and only controls the Cost Management Export anchor (`parent_id`). Role assignments and subscription enumeration are driven entirely by `management_group_ids`.

Requirements when this flag is on:
- `management_group_ids` **must** be a non-empty list. Each entry must be a management group resource ID in the form `/providers/Microsoft.Management/managementGroups/{name}`; other shapes fail variable validation.
- The provider's default subscription **must** be a member of at least one of the listed management groups (directly or via a child management group). The module fails fast otherwise.

```hcl
module "attribute-sensor" {
  source  = "ZouzIO/attribute-sensor/azurerm"
  version = "~> 2"

  organization_id = var.organization_id
  token           = var.token

  scope_wide_registration = true
  management_group_ids = [
    "/providers/Microsoft.Management/managementGroups/00000000-0000-0000-0000-000000000000",
  ]

  # Optional: anchor the Cost Management Export at a billing account instead
  # of the provider's default subscription.
  billing_account_id = "/providers/Microsoft.Billing/billingAccounts/0000000-0000-0000-0000-000000000000:00000002-0002-0002-0002-000000000000_2019-05-31"
}
```
## Adding tags to created resources
Two inputs can be used to add tags to the created resources:
- `general_tags` - a map of tags to be added to all resources provisioned by the module
- `resource_tags` - a map of tags to be added to specific resources


`general_tags` will be merged with `resource_tags` for a specific resource, i.e.:
```hcl
module "attribute-sensor" {
  # Some fields omitted for brevity

  general_tags = {
    "managed_by" = "Terraform"
    "module"     = "attribute-sensor"
  }

  resource_tags = {
    "resource_group" = {
      "used_by" = "attribute-sensor"
    }
  }
}
```
will result in the following tags for the S3 bucket:
```hcl
{
  "managed_by" = "Terraform"
  "module"     = "attribute-sensor"
  "used_by"    = "attribute-sensor"
}
```
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | >= 2.0.0, < 3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0, <5.0 |
| <a name="requirement_modtm"></a> [modtm](#requirement\_modtm) | >= 0.3.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | >= 2.0.0, < 3.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0, <5.0 |
| <a name="provider_http"></a> [http](#provider\_http) | n/a |
| <a name="provider_modtm"></a> [modtm](#provider\_modtm) | >= 0.3.5 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azapi_resource.export](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azurerm_federated_identity_credential.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.subscription](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_storage_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_container.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_user_assigned_identity.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_management_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/management_group) | data source |
| [azurerm_subscription.registration](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |
| [azurerm_subscription.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |
| [http_http.attribute_registration](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |
| [modtm_module_source.this](https://registry.terraform.io/providers/azure/modtm/latest/docs/data-sources/module_source) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_organization_id"></a> [organization\_id](#input\_organization\_id) | (**Required**) The Organization ID provided by Attribute. | `string` | n/a | yes |
| <a name="input_token"></a> [token](#input\_token) | (**Required**) The token to authenticate with the Attribute API. | `string` | n/a | yes |
| <a name="input_billing_account_id"></a> [billing\_account\_id](#input\_billing\_account\_id) | (*Optional*) The resource ID used as the Cost Management Export's `parent_id`. Accepts any supported Cost Management scope — most commonly a Billing Account (`/providers/Microsoft.Billing/billingAccounts/{id}`) or a Management Group (`/providers/Microsoft.Management/managementGroups/{name}`). When `scope_wide_registration = true`, this must be a management group resource ID. The variable name is historical. If empty, the export is anchored at the provider's default subscription. | `string` | `""` | no |
| <a name="input_blob_storage_allowlist"></a> [blob\_storage\_allowlist](#input\_blob\_storage\_allowlist) | (*Optional*) Whether to enforce the allowlist on the storage account. Defaults to false. | `bool` | `false` | no |
| <a name="input_cost_export_name"></a> [cost\_export\_name](#input\_cost\_export\_name) | (*Optional*) The name of the Cost Management Export. If not provided, a default name will be generated. | `string` | `"AttributeExport"` | no |
| <a name="input_create_costs_export"></a> [create\_costs\_export](#input\_create\_costs\_export) | (*Optional*) Whether to create the Cost Management Export. Defaults to true. | `bool` | `true` | no |
| <a name="input_general_tags"></a> [general\_tags](#input\_general\_tags) | (*Optional*) The tags to apply to the resources created by the module. | `map(string)` | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | (*Optional*) Resources location. Defaults to East US. | `string` | `"East US"` | no |
| <a name="input_managed_identity_name"></a> [managed\_identity\_name](#input\_managed\_identity\_name) | (*Optional*) The name of the managed identity. If not provided, the managed identity name will be `Attribute`. | `string` | `"Attribute"` | no |
| <a name="input_management_group_ids"></a> [management\_group\_ids](#input\_management\_group\_ids) | (*Optional*) List of management group resource IDs (each `/providers/Microsoft.Management/managementGroups/{name}`). Required when `scope_wide_registration = true`: the module creates a `Monitoring Reader` role assignment at each listed management group and registers every subscription under any of them (recursively, via `all_subscription_ids`). | `list(string)` | `[]` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (*Optional*) The name of the resource group. If not provided, the resource group name will be `Attribute`. | `string` | `"Attribute"` | no |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | (*Optional*) Additional tags to apply to specific resources created by the module. | `map(map(string))` | `{}` | no |
| <a name="input_scope_wide_registration"></a> [scope\_wide\_registration](#input\_scope\_wide\_registration) | (*Optional*) When true, the `Monitoring Reader` role assignment is created at the scope given by `billing_account_id` (which must be a management group resource ID), and the module registers every subscription under that management group (recursively) with Attribute instead of only the provider's default subscription. Cost Management Export fields are only sent in the registration for the provider's default subscription. | `bool` | `false` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | (*Optional*) The name of the storage account. If not provided, the storage account name will be extracted from the provider. | `string` | `""` | no |
| <a name="input_storage_container_name"></a> [storage\_container\_name](#input\_storage\_container\_name) | (*Optional*) The name of the storage container. If not provided, the storage container name will be generated from the subscription id. | `string` | `"exports"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_id"></a> [client\_id](#output\_client\_id) | n/a |
| <a name="output_cost_export_id"></a> [cost\_export\_id](#output\_cost\_export\_id) | Full Azure resource ID of the Cost Management Export. Null when `create_costs_export = false`. The leading segment up to `/providers/Microsoft.CostManagement/exports/<name>` is the scope (`parent_id`) the export is anchored at. |
| <a name="output_registered_subscription_ids"></a> [registered\_subscription\_ids](#output\_registered\_subscription\_ids) | Subscription IDs that the module registered with Attribute. A single-element list (the provider's default subscription) when `scope_wide_registration = false`; every subscription under `billing_account_id` (recursively, via `all_subscription_ids`) when `true`. |
| <a name="output_registration_details"></a> [registration\_details](#output\_registration\_details) | Details of the registration request sent to the Attribute Sensor API. |
| <a name="output_storage_account_url"></a> [storage\_account\_url](#output\_storage\_account\_url) | n/a |
| <a name="output_storage_container"></a> [storage\_container](#output\_storage\_container) | n/a |
| <a name="output_subscription_id"></a> [subscription\_id](#output\_subscription\_id) | n/a |
<!-- END_TF_DOCS -->