output "registration_details" {
  description = "Details of the registration request sent to the Attribute Sensor API."
  value = {
    "organization_id"     = var.organization_id
    "tenant_id"           = data.azurerm_subscription.this.tenant_id
    "subscription_id"     = data.azurerm_subscription.this.subscription_id
    "subscription_name"   = data.azurerm_subscription.this.display_name
    "billing_account_id"  = var.billing_account_id != "" ? var.billing_account_id : null
    "client_id"           = azurerm_user_assigned_identity.this.client_id
    "storage_container"   = var.create_costs_export ? azurerm_storage_container.this.0.name : null
    "storage_dir"         = var.create_costs_export ? "focus/${var.cost_export_name}" : null
    "storage_account_url" = var.create_costs_export ? azurerm_storage_account.this.0.primary_blob_endpoint : null
    "storage_info"        = local.has_existing_export ? local.existing_export_storage_infos : null
    "module_info" = {
      "version" = data.modtm_module_source.this.module_version
      "source"  = data.modtm_module_source.this.module_source
    }
  }
}

output "client_id" {
  value = azurerm_user_assigned_identity.this.client_id
}

output "storage_container" {
  value = var.create_costs_export ? azurerm_storage_container.this.0.name : null
}

output "storage_account_url" {
  value = var.create_costs_export ? azurerm_storage_account.this.0.primary_blob_endpoint : null
}

output "storage_info" {
  description = "The list of existing Cost Management Exports forwarded as the registration's `storage_info`. Each entry carries `storage_container`, `storage_dir`, the derived `storage_account_url` and `storage_export_type`. Null when no `existing_exports` is provided."
  value       = local.has_existing_export ? local.existing_export_storage_infos : null
}

output "subscription_id" {
  value = data.azurerm_subscription.this.subscription_id
}

output "registered_subscription_ids" {
  description = "Subscription IDs that the module registered with Attribute. A single-element list (the provider's default subscription) when `scope_wide_registration = false`; every subscription under `billing_account_id` (recursively, via `all_subscription_ids`) when `true`."
  value       = local.registration_subscription_ids
}

output "cost_export_id" {
  description = "Full Azure resource ID of the Cost Management Export. Null when `create_costs_export = false`. The leading segment up to `/providers/Microsoft.CostManagement/exports/<name>` is the scope (`parent_id`) the export is anchored at."
  value       = var.create_costs_export ? azapi_resource.export[0].id : null
}
