data "azurerm_subscription" "this" {
  lifecycle {
    precondition {
      condition     = !var.scope_wide_registration || length(var.management_group_ids) > 0
      error_message = "scope_wide_registration = true requires management_group_ids to be a non-empty list."
    }
  }
}

data "modtm_module_source" "this" {
  module_path = path.module
}

data "azurerm_management_group" "this" {
  for_each = local.management_group_names
  name     = each.value
}

data "azurerm_subscription" "registration" {
  for_each        = toset(local.registration_subscription_ids)
  subscription_id = each.key
}
