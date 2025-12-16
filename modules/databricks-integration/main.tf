data "databricks_current_user" "self" {}

data "databricks_sql_warehouse" "this" {
  count = local.is_sql_warehouse_compute ? 1 : 0
  name  = var.compute.name
}

data "databricks_cluster" "this" {
  count        = local.is_cluster_compute ? 1 : 0
  cluster_name = var.compute.name
}


resource "databricks_service_principal" "this" {
  display_name   = var.service_principal_name
  application_id = var.managed_identity_client_id

  databricks_sql_access    = true
  disable_as_user_deletion = false
}

resource "databricks_permissions" "cluster_autostart" {
  count = local.is_cluster_compute ? 1 : 0

  cluster_id = data.databricks_cluster.this[0].id

  access_control {
    service_principal_name = databricks_service_principal.this.application_id
    permission_level       = "CAN_RESTART"
  }

  access_control {
    service_principal_name = databricks_service_principal.this.application_id
    permission_level       = "CAN_ATTACH_TO"
  }
}

resource "databricks_permission_assignment" "workspace_user" {
  principal_id = databricks_service_principal.this.id
  permissions  = ["USER"]
}

resource "databricks_grant" "catalog" {
  depends_on = [databricks_permission_assignment.workspace_user]

  principal  = var.managed_identity_client_id
  privileges = ["USE_CATALOG"]
  catalog    = var.system_catalog
}

resource "databricks_grant" "schema" {
  depends_on = [databricks_permission_assignment.workspace_user]

  principal  = var.managed_identity_client_id
  privileges = ["USE_SCHEMA"]
  schema     = "${var.system_catalog}.${var.billing_schema}"
}

resource "databricks_grant" "table" {
  depends_on = [databricks_permission_assignment.workspace_user]

  principal  = var.managed_identity_client_id
  privileges = ["SELECT"]
  table      = "${var.system_catalog}.${var.billing_schema}.${var.usage_table}"
}
