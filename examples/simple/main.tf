module "attribute-sensor" {
  source  = "ZouzIO/attribute-sensor/azurerm"
  version = "~> 1.0"

  organization_id = var.organization_id
  token           = var.token
}
