locals {
  principal_roles = [
    "Monitoring Reader",
  ]

  storage_account_name = var.storage_account_name == "" ? "attrb${substr(md5(data.azurerm_subscription.this.subscription_id), 0, 15)}" : var.storage_account_name
  export_scope         = var.billing_account_id != "" ? var.billing_account_id : data.azurerm_subscription.this.id

  resource_group_tags         = merge(try(var.resource_tags["resource_group"], {}), var.general_tags)
  storage_account_tags        = merge(try(var.resource_tags["storage_account"], {}), var.general_tags)
  user_assigned_identity_tags = merge(try(var.resource_tags["user_assigned_identity"], {}), var.general_tags)
}
