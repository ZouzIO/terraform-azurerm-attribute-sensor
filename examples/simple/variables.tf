variable "organization_id" {
  type        = string
  description = "(Required) The Organization ID provided by Attribute"
}

variable "token" {
  type        = string
  description = "(Required) The token to authenticate with the Attribute API"
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

variable "managed_identity_name" {
  type        = string
  description = "(*Optional*) The name of the managed identity. If not provided, the managed identity name will be `Attribute`."
  default     = "Attribute"
}

variable "create_costs_export" {
  type        = bool
  description = "(*Optional*) Whether to create the costs export resources."
  default     = true
}

variable "existing_export" {
  type = object({
    storage_container   = string
    storage_dir         = string
    storage_account_id  = string
    storage_export_type = string
  })
  description = "(*Optional*) Passed through to the module's `existing_export` input."
  default     = null
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

variable "location" {
  type        = string
  description = "(*Optional*) Resources location. Defaults to East US."
  default     = "East US"
}

variable "billing_account_id" {
  type        = string
  description = "(*Optional*) Passed through to the module's `billing_account_id` input."
  default     = ""
}

variable "scope_wide_registration" {
  type        = bool
  description = "(*Optional*) Passed through to the module's `scope_wide_registration` input."
  default     = false
}

variable "management_group_ids" {
  type        = list(string)
  description = "(*Optional*) Passed through to the module's `management_group_ids` input."
  default     = []
}
