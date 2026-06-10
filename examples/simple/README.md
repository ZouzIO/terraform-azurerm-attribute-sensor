## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | >= 2.0.0, < 3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_attribute-sensor"></a> [attribute-sensor](#module\_attribute-sensor) | ../.. | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_billing_account_id"></a> [billing\_account\_id](#input\_billing\_account\_id) | (*Optional*) Passed through to the module's `billing_account_id` input. | `string` | `""` | no |
| <a name="input_cost_export_name"></a> [cost\_export\_name](#input\_cost\_export\_name) | (*Optional*) The name of the Cost Management Export. If not provided, a default name will be generated. | `string` | `"AttributeExport"` | no |
| <a name="input_create_costs_export"></a> [create\_costs\_export](#input\_create\_costs\_export) | (*Optional*) Whether to create the costs export resources. | `bool` | `true` | no |
| <a name="input_existing_exports"></a> [existing\_exports](#input\_existing\_exports) | (*Optional*) Passed through to the module's `existing_exports` input. | <pre>list(object({<br/>    storage_container   = string<br/>    storage_dir         = string<br/>    storage_account_id  = string<br/>    storage_export_type = string<br/>  }))</pre> | `null` | no |
| <a name="input_general_tags"></a> [general\_tags](#input\_general\_tags) | (*Optional*) The tags to apply to the resources created by the module. | `map(string)` | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | (*Optional*) Resources location. Defaults to East US. | `string` | `"East US"` | no |
| <a name="input_managed_identity_name"></a> [managed\_identity\_name](#input\_managed\_identity\_name) | (*Optional*) The name of the managed identity. If not provided, the managed identity name will be `Attribute`. | `string` | `"Attribute"` | no |
| <a name="input_management_group_ids"></a> [management\_group\_ids](#input\_management\_group\_ids) | (*Optional*) Passed through to the module's `management_group_ids` input. | `list(string)` | `[]` | no |
| <a name="input_organization_id"></a> [organization\_id](#input\_organization\_id) | (Required) The Organization ID provided by Attribute | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (*Optional*) The name of the resource group. If not provided, the resource group name will be `Attribute`. | `string` | `"Attribute"` | no |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | (*Optional*) Additional tags to apply to specific resources created by the module. | `map(map(string))` | `{}` | no |
| <a name="input_scope_wide_registration"></a> [scope\_wide\_registration](#input\_scope\_wide\_registration) | (*Optional*) Passed through to the module's `scope_wide_registration` input. | `bool` | `false` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | (*Optional*) The name of the storage account. If not provided, the storage account name will be extracted from the provider. | `string` | `""` | no |
| <a name="input_token"></a> [token](#input\_token) | (Required) The token to authenticate with the Attribute API | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_client_id"></a> [client\_id](#output\_client\_id) | n/a |
| <a name="output_cost_export_id"></a> [cost\_export\_id](#output\_cost\_export\_id) | n/a |
| <a name="output_registered_subscription_ids"></a> [registered\_subscription\_ids](#output\_registered\_subscription\_ids) | n/a |
| <a name="output_registration_details"></a> [registration\_details](#output\_registration\_details) | n/a |
| <a name="output_storage_account_url"></a> [storage\_account\_url](#output\_storage\_account\_url) | n/a |
| <a name="output_storage_container"></a> [storage\_container](#output\_storage\_container) | Forward the module outputs directly — the module already returns the right value for created exports, existing exports, or neither. |
