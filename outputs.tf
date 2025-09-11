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
    "storage_dir"         = var.create_costs_export ? "focus/AttributeExport" : null
    "storage_account_url" = var.create_costs_export ? azurerm_storage_account.this.0.primary_blob_endpoint : null
    "module_info" = {
      "version" = data.modtm_module_source.this.module_version
      "source"  = data.modtm_module_source.this.module_source
    }
  }
}
