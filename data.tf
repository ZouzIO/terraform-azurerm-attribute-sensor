data "azurerm_subscription" "current" {}
data "modtm_module_source" "this" {
  module_path = path.module
}
