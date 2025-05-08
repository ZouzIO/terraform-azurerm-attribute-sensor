# terraform-azure-attribute-sensor
The module provisions all required infrastracture resources for the Attribute Sensor to operate. Please, refer to the [Inputs](#inputs) section for the configuration options.
## Resources created
The module creates the following resources:
- Resource group
- Storage Account to store the Billing Export data
- Managed Identity
- Billing Data Export

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | >= 2.0.0, < 3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0, <5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | >= 2.0.0, < 3.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0, <5.0 |
| <a name="provider_http"></a> [http](#provider\_http) | n/a |

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
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |
| [http_http.attribute_registration](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_organization_id"></a> [organization\_id](#input\_organization\_id) | (**Required**) The Organization ID provided by Attribute. | `string` | n/a | yes |
| <a name="input_token"></a> [token](#input\_token) | (**Required**) The token to authenticate with the Attribute API. | `string` | n/a | yes |
| <a name="input_managed_identity_name"></a> [managed\_identity\_name](#input\_managed\_identity\_name) | (*Optional*) The name of the managed identity. If not provided, the managed identity name will be extracted with the datasource. | `string` | `"Attribute"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (*Optional*) The name of the resource group. If not provided, the resource group name will be extracted with the datasource. | `string` | `"Attribute"` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | (*Optional*) The name of the storage account. If not provided, the storage account name will be extracted with the datasource. | `string` | `""` | no |
| <a name="input_storage_container_name"></a> [storage\_container\_name](#input\_storage\_container\_name) | (*Optional*) The name of the storage container. If not provided, the storage container name will be extracted with the datasource. | `string` | `"exports"` | no |
| <a name="input_subscription_name"></a> [subscription\_name](#input\_subscription\_name) | (*Optional*) The Azure Subscription name. If not provided, the subscription name will be extracted with the datasource. | `string` | `""` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->