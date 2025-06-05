<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | >= 2.0.0, < 3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_attribute-sensor"></a> [attribute-sensor](#module\_attribute-sensor) | ZouzIO/attribute-sensor/azurerm | ~> 1.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_organization_id"></a> [organization\_id](#input\_organization\_id) | (Required) The Organization ID provided by Attribute | `string` | n/a | yes |
| <a name="input_token"></a> [token](#input\_token) | (Required) The token to authenticate with the Attribute API | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->