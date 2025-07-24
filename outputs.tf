output "registration_details" {
  description = "Details of the registration request sent to the Attribute Sensor API."
  value = {
    "organization_id"     = var.organization_id
    "tenant_id"           = data.azurerm_subscription.current.tenant_id
    "subscription_id"     = data.azurerm_subscription.current.subscription_id
    "subscription_name"   = var.subscription_name == "" ? data.azurerm_subscription.current.display_name : var.subscription_name
    "client_id"           = azurerm_user_assigned_identity.this.client_id
    "storage_container"   = azurerm_storage_container.this.name
    "storage_dir"         = "focus/AttributeExport"
    "storage_account_url" = azurerm_storage_account.this.primary_blob_endpoint
    "module_info" = {
      "version" = data.modtm_module_source.this.module_version
      "source"  = data.modtm_module_source.this.module_source
    }
  }
}
