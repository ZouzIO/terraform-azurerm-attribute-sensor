data "http" "attribute_registration" {
  for_each = data.azurerm_subscription.registration

  request_headers = {
    "Content-Type"  = "application/json"
    "Authorization" = "Bearer ${var.token}"
  }

  url    = "https://sensor.app.attrb.io/api/v1/azure"
  method = "POST"

  request_body = jsonencode(
    merge(
      {
        organization_id    = var.organization_id
        tenant_id          = each.value.tenant_id
        subscription_id    = each.value.subscription_id
        subscription_name  = each.value.display_name
        client_id          = azurerm_user_assigned_identity.this.client_id
        billing_account_id = var.billing_account_id != "" ? var.billing_account_id : null
        module_info = {
          version = data.modtm_module_source.this.module_version
          source  = data.modtm_module_source.this.module_source
        }
      },
      (each.key == data.azurerm_subscription.this.subscription_id && var.create_costs_export) ? {
        storage_container   = azurerm_storage_container.this[0].name
        storage_dir         = "focus/${var.cost_export_name}"
        storage_account_url = azurerm_storage_account.this[0].primary_blob_endpoint
      } : {},
      (each.key == data.azurerm_subscription.this.subscription_id && local.has_existing_export) ? {
        # Existing exports are sent only as the storage_info list — the legacy
        # singular storage_* fields are deliberately omitted here.
        storage_info = local.existing_export_storage_infos
      } : {}
    )
  )

  depends_on = [
    azurerm_role_assignment.subscription,
    azurerm_federated_identity_credential.this,
    azurerm_role_assignment.storage_account,
    azurerm_role_assignment.existing_exports,
    azapi_resource.export
  ]
}
