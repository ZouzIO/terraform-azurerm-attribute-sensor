data "azurerm_subscription" "this" {}

data "modtm_module_source" "this" {
  module_path = path.module
}

data "azurerm_management_group" "this" {
  count = var.scope_wide_registration ? 1 : 0
  name  = local.management_group_name

  lifecycle {
    precondition {
      condition     = local.management_group_name != null
      error_message = "When scope_wide_registration = true, billing_account_id must be a management group resource ID in the form /providers/Microsoft.Management/managementGroups/{name}."
    }
  }
}

data "azurerm_subscription" "registration" {
  for_each        = toset(local.registration_subscription_ids)
  subscription_id = each.key
}
