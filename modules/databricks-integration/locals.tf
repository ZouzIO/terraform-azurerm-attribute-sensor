locals {
  is_sql_warehouse_compute = var.compute.type == "SQL"
  is_cluster_compute       = var.compute.type == "Cluster"

  databricks_sql_endpoint = (
    local.is_sql_warehouse_compute ?
    data.databricks_sql_warehouse.this.0.odbc_params.0.path :
    format(
      "sql/protocolv1/o/%s/%s",
      regex("https://adb-(\\d+)\\.", data.databricks_current_user.self.workspace_url)[0],
      data.databricks_cluster.this.0.cluster_id
    )
  )
}

data "azurerm_subscription" "this" {}
