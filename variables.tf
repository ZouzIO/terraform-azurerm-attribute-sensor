variable "organization_id" {
  type        = string
  description = "(**Required**) The Organization ID provided by Attribute."
}

variable "token" {
  type        = string
  description = "(**Required**) The token to authenticate with the Attribute API."
}

variable "subscription_name" {
  type        = string
  description = "(*Optional*) The Azure Subscription name. If not provided, the subscription name will be extracted with the datasource."
  default     = ""
}

variable "resource_group_name" {
  type        = string
  description = "(*Optional*) The name of the resource group. If not provided, the resource group name will be extracted with the datasource."
  default     = "Attribute"
}

variable "storage_account_name" {
  type        = string
  description = "(*Optional*) The name of the storage account. If not provided, the storage account name will be extracted with the datasource."
  default     = ""
}

variable "storage_container_name" {
  type        = string
  description = "(*Optional*) The name of the storage container. If not provided, the storage container name will be extracted with the datasource."
  default     = "exports"
}
variable "managed_identity_name" {
  type        = string
  description = "(*Optional*) The name of the managed identity. If not provided, the managed identity name will be extracted with the datasource."
  default     = "Attribute"
}

variable "blob_storage_allowlist" {
  type        = bool
  description = "(*Optional*) Whether to enforce the allowlist on the storage account. Defaults to false."
  default     = false
}
