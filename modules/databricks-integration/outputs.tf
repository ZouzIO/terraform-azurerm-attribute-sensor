output "workspace_details" {
  value = {
    (var.location) = {
      "sql_endpoint" = local.databricks_sql_endpoint,
      "sql_host"     = data.databricks_current_user.self.workspace_url,
      "usage_table"  = "${var.system_catalog}.${var.billing_schema}.${var.usage_table}"
    }
  }
}
