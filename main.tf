
resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = "East US"
}

resource "azurerm_storage_account" "this" {
  name                = local.storage_account_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "this" {
  name = var.storage_container_name

  storage_account_id = azurerm_storage_account.this.id
}

resource "azurerm_user_assigned_identity" "this" {
  location            = azurerm_resource_group.this.location
  name                = var.managed_identity_name
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_federated_identity_credential" "this" {
  name                = "attribute"
  resource_group_name = azurerm_resource_group.this.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://accounts.google.com"
  parent_id           = azurerm_user_assigned_identity.this.id
  subject             = "108313149922577077162"
}

resource "azurerm_role_assignment" "storage_account" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}

resource "azurerm_role_assignment" "subscription" {
  for_each             = toset(local.principal_roles)
  scope                = data.azurerm_subscription.current.id
  role_definition_name = each.key
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}

resource "azapi_resource" "export" {
  type      = "Microsoft.CostManagement/exports@2023-07-01-preview"
  parent_id = data.azurerm_subscription.current.id
  name      = "AttributeExport"
  location  = "global"

  body = {
    properties = {
      definition = {
        type      = "FocusCost"
        timeframe = "MonthToDate"
        dataSet = {
          configuration = {
            dataVersion = "1.0"
          }
          granularity = "Daily"
        }
      }
      deliveryInfo = {
        "destination" : {
          resourceId     = azurerm_storage_account.this.id
          container      = azurerm_storage_container.this.name
          rootFolderPath = "focus"
          type           = "AzureBlob"
        }
      }
      schedule = {
        recurrence : "Daily"
        recurrencePeriod = {
          from = "2025-05-05T00:00:00Z"
          to   = "2050-01-01T00:00:00Z"
        }
        status = "Active"
      }
      format                = "Csv"
      partitionData         = true
      dataOverwriteBehavior = "OverwritePreviousReport"
      compressionMode       = "None"
      exportDescription     = "Attribute FOCUS Export"
    }
  }
}
