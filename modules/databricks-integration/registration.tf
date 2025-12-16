data "http" "attribute_registration" {
  request_headers = {
    "Content-Type"  = "application/json"
    "Authorization" = "Bearer ${var.token}"
  }

  url    = "https://sensor.app.attrb.io/api/v1/azure/databricks"
  method = "POST"

  request_body = jsonencode(
    {
      organization_id = var.organization_id
      subscription_id = data.azurerm_subscription.this.subscription_id
      databricks = {
        (var.location) = {
          "sql_endpoint" = local.databricks_sql_endpoint,
          "sql_host"     = data.databricks_current_user.self.workspace_url,
          "usage_table"  = "${var.system_catalog}.${var.billing_schema}.${var.usage_table}"
        }
      }
    }
  )

  # depends_on = [
  # ]
}
