variable "organization_id" {
  type        = string
  description = "(**Required**) The Organization ID provided by Attribute."
}

variable "subscription_name" {
  type        = string
  description = "(*Optional*) The Azure Subscription name. If not provided, the account name will be extracted with the datasource."
  default     = ""
}

variable "token" {
  type        = string
  description = "(**Required**) The token to authenticate with the Attribute API."
}
