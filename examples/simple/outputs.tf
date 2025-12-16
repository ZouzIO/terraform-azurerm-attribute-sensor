output "client_id" {
  value = module.attribute-sensor.client_id
}

output "storage_container" {
  value = var.create_costs_export ? module.attribute-sensor.storage_container : null
}

output "storage_account_url" {
  value = var.create_costs_export ? module.attribute-sensor.storage_account_url : null
}
