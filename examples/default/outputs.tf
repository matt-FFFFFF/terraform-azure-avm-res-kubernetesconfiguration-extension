output "resource_id" {
  description = "The ID of the extension resource."
  value       = module.kubernetes_extension.resource_id
}

output "name" {
  description = "The name of the extension resource."
  value       = module.kubernetes_extension.name
}
