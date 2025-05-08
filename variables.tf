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
