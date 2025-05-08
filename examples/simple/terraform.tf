terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = ">= 2.0.0, < 3.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = "your-subscription-id"
}
