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
## Providing the Billing Account ID
By default, the Billing Export will be created at the subscription scope. If you want to create the export at the billing account scope, you need to provide the `billing_account_id` input variable, i.e.:

_`billing_account_id` must be in the format `/providers/Microsoft.Billing/billingAccounts/{billingAccountId}`, i.e. `/providers/Microsoft.Billing/billingAccounts/0000000-0000-0000-0000-000000000000:00000002-0002-0002-0002-000000000000_2019-05-31`_


```hcl
module "attribute-sensor" {
  source  = "ZouzIO/attribute-sensor/azurerm"
  version = "2.0.1"

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
  version = "2.0.1"

  organization_id     = var.organization_id
  token               = var.token

  create_costs_export = false
}
```
In that case, only the Resource Group and Managed Identity will be created, skipping the Storage Account and Billing Export creation.
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

| Name                                                                | Version         |
| ------------------------------------------------------------------- | --------------- |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi)       | >= 2.0.0, < 3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0, <5.0    |
| <a name="requirement_modtm"></a> [modtm](#requirement\_modtm)       | >= 0.3.5        |

## Providers

| Name                                                          | Version         |
| ------------------------------------------------------------- | --------------- |
| <a name="provider_azapi"></a> [azapi](#provider\_azapi)       | >= 2.0.0, < 3.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0, <5.0    |
| <a name="provider_http"></a> [http](#provider\_http)          | n/a             |
| <a name="provider_modtm"></a> [modtm](#provider\_modtm)       | >= 0.3.5        |

## Modules

No modules.

## Resources

| Name                                                                                                                                                        | Type        |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [azapi_resource.export](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource)                                                 | resource    |
| [azurerm_federated_identity_credential.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) | resource    |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group)                               | resource    |
| [azurerm_role_assignment.storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment)                  | resource    |
| [azurerm_role_assignment.subscription](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment)                     | resource    |
| [azurerm_storage_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account)                             | resource    |
| [azurerm_storage_container.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container)                         | resource    |
| [azurerm_user_assigned_identity.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity)               | resource    |
| [azurerm_subscription.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription)                                | data source |
| [http_http.attribute_registration](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http)                                    | data source |
| [modtm_module_source.this](https://registry.terraform.io/providers/azure/modtm/latest/docs/data-sources/module_source)                                      | data source |

## Inputs

| Name                                                                                                     | Description                                                                                                                             | Type               | Default             | Required |
| -------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- | ------------------ | ------------------- | :------: |
| <a name="input_organization_id"></a> [organization\_id](#input\_organization\_id)                        | (**Required**) The Organization ID provided by Attribute.                                                                               | `string`           | n/a                 |   yes    |
| <a name="input_token"></a> [token](#input\_token)                                                        | (**Required**) The token to authenticate with the Attribute API.                                                                        | `string`           | n/a                 |   yes    |
| <a name="input_billing_account_id"></a> [billing\_account\_id](#input\_billing\_account\_id)             | (*Optional*) The Billing Account ID. If not provided, the Costs Export scope will be the providers subscription.                        | `string`           | `""`                |    no    |
| <a name="input_blob_storage_allowlist"></a> [blob\_storage\_allowlist](#input\_blob\_storage\_allowlist) | (*Optional*) Whether to enforce the allowlist on the storage account. Defaults to false.                                                | `bool`             | `false`             |    no    |
| <a name="input_cost_export_name"></a> [cost\_export\_name](#input\_cost\_export\_name)                   | (*Optional*) The name of the Cost Management Export. If not provided, a default name will be generated.                                 | `string`           | `"AttributeExport"` |    no    |
| <a name="input_create_costs_export"></a> [create\_costs\_export](#input\_create\_costs\_export)          | (*Optional*) Whether to create the Cost Management Export. Defaults to true.                                                            | `bool`             | `true`              |    no    |
| <a name="input_general_tags"></a> [general\_tags](#input\_general\_tags)                                 | (*Optional*) The tags to apply to the resources created by the module.                                                                  | `map(string)`      | `{}`                |    no    |
| <a name="input_location"></a> [location](#input\_location)                                               | (*Optional*) Resources location. Defaults to East US.                                                                                   | `string`           | `"East US"`         |    no    |
| <a name="input_managed_identity_name"></a> [managed\_identity\_name](#input\_managed\_identity\_name)    | (*Optional*) The name of the managed identity. If not provided, the managed identity name will be `Attribute`.                          | `string`           | `"Attribute"`       |    no    |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)          | (*Optional*) The name of the resource group. If not provided, the resource group name will be `Attribute`.                              | `string`           | `"Attribute"`       |    no    |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags)                              | (*Optional*) Additional tags to apply to specific resources created by the module.                                                      | `map(map(string))` | `{}`                |    no    |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name)       | (*Optional*) The name of the storage account. If not provided, the storage account name will be extracted from the provider.            | `string`           | `""`                |    no    |
| <a name="input_storage_container_name"></a> [storage\_container\_name](#input\_storage\_container\_name) | (*Optional*) The name of the storage container. If not provided, the storage container name will be generated from the subscription id. | `string`           | `"exports"`         |    no    |

## Outputs

| Name                                                                                               | Description                                                           |
| -------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------- |
| <a name="output_client_id"></a> [client\_id](#output\_client\_id)                                  | n/a                                                                   |
| <a name="output_registration_details"></a> [registration\_details](#output\_registration\_details) | Details of the registration request sent to the Attribute Sensor API. |
| <a name="output_storage_account_url"></a> [storage\_account\_url](#output\_storage\_account\_url)  | n/a                                                                   |
| <a name="output_storage_container"></a> [storage\_container](#output\_storage\_container)          | n/a                                                                   |
| <a name="output_subscription_id"></a> [subscription\_id](#output\_subscription\_id)                | n/a                                                                   |
<!-- END_TF_DOCS -->