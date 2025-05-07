output "sub_name" {
  value       = data.azurerm_subscription.current.display_name
  description = "The name of the Azure subscription."
}
