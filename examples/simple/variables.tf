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
