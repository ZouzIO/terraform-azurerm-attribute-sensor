output "client_id" {
  value = module.attribute-sensor.client_id
}

# Forward the module outputs directly — the module already returns the right
# value for created exports, existing exports, or neither.
output "storage_container" {
  value = module.attribute-sensor.storage_container
}

output "storage_account_url" {
  value = module.attribute-sensor.storage_account_url
}

output "registered_subscription_ids" {
  value = module.attribute-sensor.registered_subscription_ids
}

output "cost_export_id" {
  value = module.attribute-sensor.cost_export_id
}

output "registration_details" {
  value = module.attribute-sensor.registration_details
}
