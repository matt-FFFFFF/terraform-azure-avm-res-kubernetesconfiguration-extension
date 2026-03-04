module "avm_interfaces" {
  source           = "git::https://github.com/Azure/terraform-azure-avm-utl-interfaces.git?ref=feat/prepv1"
  parent_id        = var.parent_id
  this_resource_id = azapi_resource.this.id
  enable_telemetry = var.enable_telemetry
  location         = var.location
}
