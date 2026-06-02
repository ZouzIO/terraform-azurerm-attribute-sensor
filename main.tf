
resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location

  tags = local.resource_group_tags
}

resource "azurerm_storage_account" "this" {
  count = var.create_costs_export ? 1 : 0

  name                = local.storage_account_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  account_tier              = "Standard"
  account_replication_type  = "LRS"
  shared_access_key_enabled = true

  dynamic "network_rules" {
    for_each = var.blob_storage_allowlist ? [1] : []
    content {
      default_action = "Deny"
      ip_rules = [
        "35.224.163.103",
        "34.41.229.120"
      ]
      bypass = ["AzureServices"]
    }
  }

  tags = local.storage_account_tags
}

resource "azurerm_storage_container" "this" {
  count = var.create_costs_export ? 1 : 0

  name               = var.storage_container_name
  storage_account_id = azurerm_storage_account.this.0.id
}

resource "azurerm_user_assigned_identity" "this" {
  location            = azurerm_resource_group.this.location
  name                = var.managed_identity_name
  resource_group_name = azurerm_resource_group.this.name

  tags = local.user_assigned_identity_tags

  lifecycle {
    precondition {
      condition     = !(var.create_costs_export && var.existing_export != null)
      error_message = "existing_export is mutually exclusive with create_costs_export. Set create_costs_export = false when providing existing_export."
    }
  }
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
  count = var.create_costs_export ? 1 : 0

  scope                = azurerm_storage_account.this.0.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}

resource "azurerm_role_assignment" "existing_export" {
  count = var.existing_export != null ? 1 : 0

  scope                = var.existing_export.storage_account_id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}

resource "azurerm_role_assignment" "subscription" {
  for_each             = local.role_assignments
  scope                = each.value.scope
  role_definition_name = each.value.role
  principal_id         = azurerm_user_assigned_identity.this.principal_id

  lifecycle {
    precondition {
      condition = !var.scope_wide_registration || anytrue([
        for mg in data.azurerm_management_group.this :
        contains(mg.all_subscription_ids, data.azurerm_subscription.this.subscription_id)
      ])
      error_message = "scope_wide_registration = true requires the provider's default subscription to be a member of at least one management group listed in management_group_ids (directly or via a child management group)."
    }
  }
}

resource "azapi_resource" "export" {
  count = var.create_costs_export ? 1 : 0

  type      = "Microsoft.CostManagement/exports@2023-07-01-preview"
  parent_id = local.export_scope
  name      = var.cost_export_name
  location  = "global"

  dynamic "identity" {
    for_each = var.blob_storage_allowlist ? [1] : []
    content {
      type = "SystemAssigned"
    }
  }

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
          resourceId     = azurerm_storage_account.this.0.id
          container      = azurerm_storage_container.this.0.name
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
