terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, <5.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = ">= 2.0.0, < 3.0"
    }
    modtm = {
      source  = "azure/modtm"
      version = ">= 0.3.5"
    }
  }
}
