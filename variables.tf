variable "organization_id" {
  type        = string
  description = "(**Required**) The Organization ID provided by Attribute."
}

variable "token" {
  type        = string
  description = "(**Required**) The token to authenticate with the Attribute API."
}

variable "create_costs_export" {
  type        = bool
  description = "(*Optional*) Whether to create the Cost Management Export. Defaults to true."
  default     = true
}

variable "billing_account_id" {
  type        = string
  description = "(*Optional*) The resource ID used as the Cost Management Export's `parent_id`. Accepts any supported Cost Management scope — most commonly a Billing Account (`/providers/Microsoft.Billing/billingAccounts/{id}`) or a Management Group (`/providers/Microsoft.Management/managementGroups/{name}`). When `scope_wide_registration = true`, this must be a management group resource ID. The variable name is historical. If empty, the export is anchored at the provider's default subscription."
  default     = ""
}

variable "scope_wide_registration" {
  type        = bool
  description = "(*Optional*) When true, the `Monitoring Reader` role assignment is created at the scope given by `billing_account_id` (which must be a management group resource ID), and the module registers every subscription under that management group (recursively) with Attribute instead of only the provider's default subscription. Cost Management Export fields are only sent in the registration for the provider's default subscription."
  default     = false
}

variable "cost_export_name" {
  type        = string
  description = "(*Optional*) The name of the Cost Management Export. If not provided, a default name will be generated."
  default     = "AttributeExport"
}

variable "resource_group_name" {
  type        = string
  description = "(*Optional*) The name of the resource group. If not provided, the resource group name will be `Attribute`."
  default     = "Attribute"
}

variable "storage_account_name" {
  type        = string
  description = "(*Optional*) The name of the storage account. If not provided, the storage account name will be extracted from the provider."
  default     = ""
}

variable "storage_container_name" {
  type        = string
  description = "(*Optional*) The name of the storage container. If not provided, the storage container name will be generated from the subscription id."
  default     = "exports"
}

variable "managed_identity_name" {
  type        = string
  description = "(*Optional*) The name of the managed identity. If not provided, the managed identity name will be `Attribute`."
  default     = "Attribute"
}

variable "blob_storage_allowlist" {
  type        = bool
  description = "(*Optional*) Whether to enforce the allowlist on the storage account. Defaults to false."
  default     = false
}

variable "location" {
  type        = string
  description = "(*Optional*) Resources location. Defaults to East US."
  default     = "East US"
}

variable "resource_tags" {
  type        = map(map(string))
  default     = {}
  description = "(*Optional*) Additional tags to apply to specific resources created by the module."
}

variable "general_tags" {
  type        = map(string)
  default     = {}
  description = "(*Optional*) The tags to apply to the resources created by the module."
}

variable "management_group_ids" {
  type        = list(string)
  description = "(*Optional*) List of management group resource IDs (each `/providers/Microsoft.Management/managementGroups/{name}`). Required when `scope_wide_registration = true`: the module creates a `Monitoring Reader` role assignment at each listed management group and registers every subscription under any of them (recursively, via `all_subscription_ids`)."
  default     = []

  validation {
    condition = alltrue([
      for id in var.management_group_ids :
      can(regex("^/providers/Microsoft\\.Management/managementGroups/.+$", id))
    ])
    error_message = "Each entry in management_group_ids must be a management group resource ID in the form /providers/Microsoft.Management/managementGroups/{name}."
  }
}
