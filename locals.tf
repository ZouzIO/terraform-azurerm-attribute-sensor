locals {
  principal_roles = [
    "Monitoring Reader",
  ]

  storage_account_name = var.storage_account_name == "" ? "attrb${substr(md5(data.azurerm_subscription.this.subscription_id), 0, 15)}" : var.storage_account_name
  # In MG-wide mode the export stays anchored at the provider's subscription
  # — the MG is only used for role-assignment scope and subscription enumeration.
  # Anchoring the export at MG scope requires the MG to contain EA subs and is
  # not the intended behavior.
  export_scope = var.billing_account_id != "" ? var.billing_account_id : data.azurerm_subscription.this.id

  # Map of MG resource ID -> short name (the {name} segment), used to drive
  # for_each on data.azurerm_management_group.this. Empty when not scope-wide.
  management_group_names = var.scope_wide_registration ? {
    for id in var.management_group_ids : id => regex("^/providers/Microsoft\\.Management/managementGroups/(.+)$", id)[0]
  } : {}

  # One role assignment per (role, scope). When scope_wide_registration is
  # false the single scope is the provider's default subscription and the key
  # is just the role name (preserved from the pre-list-MG shape so existing
  # state is unaffected). When true, the key is "role|MG_id".
  role_assignments = var.scope_wide_registration ? {
    for pair in setproduct(local.principal_roles, var.management_group_ids) :
    "${pair[0]}|${pair[1]}" => { role = pair[0], scope = pair[1] }
    } : {
    for role in local.principal_roles :
    role => { role = role, scope = data.azurerm_subscription.this.id }
  }

  registration_subscription_ids = var.scope_wide_registration ? distinct(flatten([
    for mg in data.azurerm_management_group.this : mg.all_subscription_ids
  ])) : [data.azurerm_subscription.this.subscription_id]

  resource_group_tags         = merge(try(var.resource_tags["resource_group"], {}), var.general_tags)
  storage_account_tags        = merge(try(var.resource_tags["storage_account"], {}), var.general_tags)
  user_assigned_identity_tags = merge(try(var.resource_tags["user_assigned_identity"], {}), var.general_tags)
}
