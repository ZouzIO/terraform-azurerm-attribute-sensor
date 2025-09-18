# terraform-azure-attribute-sensor
The module provisions all required infrastracture resources for the Attribute Sensor to operate. Please, refer to the [Inputs](#inputs) section for the configuration options.
## Resources created
The module creates the following resources:
- Resource group
- Storage Account to store the Billing Export data
- Managed Identity
- Billing Data Export

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
| [azurerm_subscription.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |
| [http_http.attribute_registration](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |
| [modtm_module_source.this](https://registry.terraform.io/providers/azure/modtm/latest/docs/data-sources/module_source) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_organization_id"></a> [organization\_id](#input\_organization\_id) | (**Required**) The Organization ID provided by Attribute. | `string` | n/a | yes |
| <a name="input_token"></a> [token](#input\_token) | (**Required**) The token to authenticate with the Attribute API. | `string` | n/a | yes |
| <a name="input_billing_account_id"></a> [billing\_account\_id](#input\_billing\_account\_id) | (*Optional*) The Billing Account ID. If not provided, the Costs Export scope will be the providers subscription. | `string` | `""` | no |
| <a name="input_blob_storage_allowlist"></a> [blob\_storage\_allowlist](#input\_blob\_storage\_allowlist) | (*Optional*) Whether to enforce the allowlist on the storage account. Defaults to false. | `bool` | `false` | no |
| <a name="input_create_costs_export"></a> [create\_costs\_export](#input\_create\_costs\_export) | (*Optional*) Whether to create the Cost Management Export. Defaults to true. | `bool` | `true` | no |
| <a name="input_managed_identity_name"></a> [managed\_identity\_name](#input\_managed\_identity\_name) | (*Optional*) The name of the managed identity. If not provided, the managed identity name will be `Attribute`. | `string` | `"Attribute"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (*Optional*) The name of the resource group. If not provided, the resource group name will be `Attribute`. | `string` | `"Attribute"` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | (*Optional*) The name of the storage account. If not provided, the storage account name will be extracted from the provider. | `string` | `""` | no |
| <a name="input_storage_container_name"></a> [storage\_container\_name](#input\_storage\_container\_name) | (*Optional*) The name of the storage container. If not provided, the storage container name will be generated from the subscription id. | `string` | `"exports"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_registration_details"></a> [registration\_details](#output\_registration\_details) | Details of the registration request sent to the Attribute Sensor API. |
<!-- END_TF_DOCS -->