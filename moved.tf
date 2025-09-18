moved {
  from = azurerm_role_assignment.storage_account
  to   = azurerm_role_assignment.storage_account[0]
}

moved {
  from = azurerm_role_assignment.azurerm_storage_container
  to   = azurerm_role_assignment.azurerm_storage_container[0]
}

moved {
  from = azurerm_role_assignment.storage_account
  to   = azurerm_role_assignment.storage_account[0]
}

moved {
  from = azapi_resource.export
  to   = azapi_resource.export[0]
}
