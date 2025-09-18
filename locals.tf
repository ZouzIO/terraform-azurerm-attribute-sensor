locals {
  principal_roles = [
    "Monitoring Reader",
  ]

  storage_account_name = var.storage_account_name == "" ? "attrb${substr(md5(data.azurerm_subscription.this.subscription_id), 0, 15)}" : var.storage_account_name
  export_scope         = var.billing_account_id != "" ? var.billing_account_id : data.azurerm_subscription.this.id
}
