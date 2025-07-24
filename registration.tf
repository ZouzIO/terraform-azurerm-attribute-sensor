data "http" "attribute_registration" {
  request_headers = {
    "Content-Type"  = "application/json"
    "Authorization" = "Bearer ${var.token}",
  }

  url    = "https://sensor.app.attrb.io/api/v1/azure"
  method = "POST"

  request_body = jsonencode(merge({
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
  }))

  depends_on = [
    azurerm_role_assignment.subscription,
    azurerm_role_assignment.storage_account,
    azurerm_federated_identity_credential.this,
    azapi_resource.export
  ]
}
