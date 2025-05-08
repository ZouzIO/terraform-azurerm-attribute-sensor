locals {
  principal_roles = [
    "Monitoring Reader",
  ]

  storage_account_name = var.storage_account_name == "" ? "attrb${substr(md5(data.azurerm_subscription.current.subscription_id), 0, 15)}" : var.storage_account_name
}
