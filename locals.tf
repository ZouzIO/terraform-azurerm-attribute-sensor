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

  # True when at least one existing export was supplied. Treats a null or empty
  # list identically: the module creates no role assignments and sends no
  # storage_info in that case.
  has_existing_export = var.existing_exports != null ? length(var.existing_exports) > 0 : false

  # One storage_info entry per existing export, forwarded verbatim in the
  # registration's `storage_info` list. The blob endpoint is derived from the
  # storage account ID rather than looked up via a data source: an existing
  # export may live in a different subscription than the provider's, where an
  # azurerm data source cannot read it. Assumes the Azure public cloud blob
  # suffix.
  existing_export_storage_infos = local.has_existing_export ? [
    for e in var.existing_exports : {
      storage_container   = e.storage_container
      storage_dir         = e.storage_dir
      storage_account_url = "https://${regex("(?i)/storageAccounts/([^/]+)$", e.storage_account_id)[0]}.blob.core.windows.net/"
      storage_export_type = e.storage_export_type
    }
  ] : []

  # Distinct storage account IDs across all existing exports — the scope for the
  # Storage Blob Data Reader role assignments. Deduped so multiple exports in the
  # same account produce a single assignment.
  existing_export_storage_account_ids = local.has_existing_export ? toset([
    for e in var.existing_exports : e.storage_account_id
  ]) : toset([])

  resource_group_tags         = merge(try(var.resource_tags["resource_group"], {}), var.general_tags)
  storage_account_tags        = merge(try(var.resource_tags["storage_account"], {}), var.general_tags)
  user_assigned_identity_tags = merge(try(var.resource_tags["user_assigned_identity"], {}), var.general_tags)
}
