output "client_id" {
  value = module.attribute-sensor.client_id
}

output "storage_container" {
  value = var.create_costs_export ? module.attribute-sensor.storage_container : null
}

output "storage_account_url" {
  value = var.create_costs_export ? module.attribute-sensor.storage_account_url : null
}

output "registered_subscription_ids" {
  value = module.attribute-sensor.registered_subscription_ids
}

output "cost_export_id" {
  value = module.attribute-sensor.cost_export_id
}
