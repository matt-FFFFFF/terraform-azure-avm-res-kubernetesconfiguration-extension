output "resource_id" {
  description = "The ID of the created extension resource."
  value       = azapi_resource.this.id
}

output "name" {
  description = "The name of the created extension resource."
  value       = azapi_resource.this.name
}

output "identity_principal_id" {
  description = "The principal ID of the extension's system-assigned managed identity."
  value       = try(azapi_resource.this.output.identity.principalId, null)
}

output "identity_tenant_id" {
  description = "The tenant ID of the extension's system-assigned managed identity."
  value       = try(azapi_resource.this.output.identity.tenantId, null)
}

output "aks_assigned_identity_principal_id" {
  description = "The principal ID of the AKS assigned identity."
  value       = try(azapi_resource.this.output.properties.aksAssignedIdentity.principalId, null)
}

output "aks_assigned_identity_tenant_id" {
  description = "The tenant ID of the AKS assigned identity."
  value       = try(azapi_resource.this.output.properties.aksAssignedIdentity.tenantId, null)
}

output "current_version" {
  description = "Currently installed version of the extension."
  value       = try(azapi_resource.this.output.properties.currentVersion, null)
}

output "custom_location_settings" {
  description = "Custom Location settings properties."
  value       = try(azapi_resource.this.output.properties.customLocationSettings, {})
}

output "error_info" {
  description = "Error information from the Agent - e.g. errors during installation."
  value       = try(azapi_resource.this.output.properties.errorInfo, {})
}

output "is_system_extension" {
  description = "Flag to note if this extension is a system extension."
  value       = try(azapi_resource.this.output.properties.isSystemExtension, null)
}

output "package_uri" {
  description = "URI of the Helm package."
  value       = try(azapi_resource.this.output.properties.packageUri, null)
}

output "provisioning_state" {
  description = "Status of installation of this extension."
  value       = try(azapi_resource.this.output.properties.provisioningState, null)
}

