data "azurerm_subscription" "this" {}

data "modtm_module_source" "this" {
  module_path = path.module
}
