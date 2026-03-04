resource "azapi_resource" "this" {
  type                   = "Microsoft.KubernetesConfiguration/extensions@2024-11-01"
  name                   = var.name
  parent_id              = var.parent_id
  body                   = local.resource_body
  sensitive_body         = local.sensitive_body
  sensitive_body_version = local.sensitive_body_version
  ignore_null_property   = true

  dynamic "identity" {
    for_each = local.managed_identities.system_assigned

    content {
      type = identity.value.type
    }
  }

  response_export_values = [
    "properties.aksAssignedIdentity.principalId",
    "properties.aksAssignedIdentity.tenantId",
    "properties.currentVersion",
    "properties.customLocationSettings",
    "properties.errorInfo",
    "properties.isSystemExtension",
    "properties.packageUri",
    "properties.provisioningState",
  ]
}
