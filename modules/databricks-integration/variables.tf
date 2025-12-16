variable "organization_id" {
  type        = string
  description = "(**Required**) The Organization ID provided by Attribute."
}

variable "token" {
  type        = string
  description = "(**Required**) The token to authenticate with the Attribute API."
}

variable "subscription_id" {
  description = "The Subscription ID where the billing extractor will operate"
  type        = string
}

variable "managed_identity_client_id" {
  description = "The Client ID of the Managed Identity used for extracting billing usage"
  type        = string
}

variable "compute" {
  description = "The Cluster ID where the billing extractor will run"
  type = object({
    type = string
    name = string
  })
  validation {
    condition     = var.compute.type == "SQL" || var.compute.type == "Cluster"
    error_message = "The compute type must be 'SQL' or 'Cluster'"
  }
}

variable "location" {
  description = "The Databricks workspace location"
  type        = string
}

variable "service_principal_name" {
  description = "The name of the Databricks Service Principal to create"
  type        = string
  default     = "Attribute billing extractor"
}

variable "system_catalog" {
  description = "The system catalog name"
  type        = string
  default     = "system"
}

variable "billing_schema" {
  description = "The billing schema name"
  type        = string
  default     = "billing"
}

variable "usage_table" {
  description = "The usage table name"
  type        = string
  default     = "usage"
}
