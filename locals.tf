locals {
  principal_roles = [
    "Monitoring Reader",
  ]

  storage_account_name = var.storage_account_name == "" ? "attrb${substr(md5(data.azurerm_subscription.this.subscription_id), 0, 15)}" : var.storage_account_name
  export_scope         = var.billing_account_id != "" ? var.billing_account_id : data.azurerm_subscription.this.id

  management_group_name = var.scope_wide_registration ? try(
    regex("^/providers/Microsoft\\.Management/managementGroups/(.+)$", var.billing_account_id)[0],
    null,
  ) : null

  principal_role_scope = var.scope_wide_registration ? var.billing_account_id : data.azurerm_subscription.this.id

  registration_subscription_ids = var.scope_wide_registration ? data.azurerm_management_group.this[0].all_subscription_ids : [data.azurerm_subscription.this.subscription_id]

  resource_group_tags         = merge(try(var.resource_tags["resource_group"], {}), var.general_tags)
  storage_account_tags        = merge(try(var.resource_tags["storage_account"], {}), var.general_tags)
  user_assigned_identity_tags = merge(try(var.resource_tags["user_assigned_identity"], {}), var.general_tags)
}
