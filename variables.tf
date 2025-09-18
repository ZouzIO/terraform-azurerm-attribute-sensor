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
  description = "(*Optional*) The Billing Account ID. If not provided, the Costs Export scope will be the providers subscription."
  default     = ""
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
