module "attribute-sensor" {
  source = "../.."

  organization_id = var.organization_id
  token           = var.token

  resource_group_name     = var.resource_group_name
  cost_export_name        = var.cost_export_name
  storage_account_name    = var.storage_account_name
  managed_identity_name   = var.managed_identity_name
  location                = var.location
  general_tags            = var.general_tags
  resource_tags           = var.resource_tags
  billing_account_id      = var.billing_account_id
  scope_wide_registration = var.scope_wide_registration
}
