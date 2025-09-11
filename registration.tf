data "http" "attribute_registration" {
  count = var.create_costs_export ? 1 : 0

  request_headers = {
    "Content-Type"  = "application/json"
    "Authorization" = "Bearer ${var.token}",
  }

  url    = "https://sensor.app.attrb.io/api/v1/azure"
  method = "POST"

  request_body = jsonencode(merge({
    "organization_id"     = var.organization_id
    "tenant_id"           = data.azurerm_subscription.this.tenant_id
    "subscription_id"     = data.azurerm_subscription.this.subscription_id
    "subscription_name"   = data.azurerm_subscription.this.display_name
    "billing_account_id"  = var.billing_account_id != "" ? var.billing_account_id : null
    "client_id"           = azurerm_user_assigned_identity.this.client_id
    "storage_container"   = azurerm_storage_container.this.0.name
    "storage_dir"         = "focus/AttributeExport"
    "storage_account_url" = azurerm_storage_account.this.0.primary_blob_endpoint
    "module_info" = {
      "version" = data.modtm_module_source.this.module_version
      "source"  = data.modtm_module_source.this.module_source
  }}))

  depends_on = [
    azurerm_role_assignment.subscription,
    azurerm_role_assignment.storage_account,
    azurerm_federated_identity_credential.this,
    azapi_resource.export
  ]
}


data "http" "attribute_sub_registration" {
  count = var.create_costs_export ? 0 : 1
  request_headers = {
    "Content-Type"  = "application/json"
    "Authorization" = "Bearer ${var.token}",
  }

  url    = "https://sensor.app.attrb.io/api/v1/azure"
  method = "POST"

  request_body = jsonencode(merge({
    "organization_id"     = var.organization_id
    "tenant_id"           = data.azurerm_subscription.this.tenant_id
    "subscription_id"     = data.azurerm_subscription.this.subscription_id
    "subscription_name"   = data.azurerm_subscription.this.display_name
    "client_id"           = azurerm_user_assigned_identity.this.client_id
    "module_info" = {
      "version" = data.modtm_module_source.this.module_version
      "source"  = data.modtm_module_source.this.module_source
  }}))
  

  depends_on = [
    azurerm_role_assignment.subscription,
    azurerm_federated_identity_credential.this,
  ]
}
