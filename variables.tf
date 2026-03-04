variable "name" {
  description = <<DESCRIPTION
The name of the extension.
DESCRIPTION
  type        = string
}

variable "parent_id" {
  description = <<DESCRIPTION
The resource ID of the Kubernetes cluster (e.g. AKS managed cluster, Arc-enabled Kubernetes cluster) on which to install the extension.
DESCRIPTION
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/[a-f0-9-]+/resourceGroups/[^/]+/providers/[^/]+/[^/]+/[^/]+$", var.parent_id))
    error_message = "parent_id must be a valid Azure resource ID, e.g. /subscriptions/{sub-id}/resourceGroups/{rg-name}/providers/Microsoft.ContainerService/managedClusters/{cluster-name}"
  }
}

variable "location" {
  description = <<DESCRIPTION
The Azure region for the telemetry deployment. This is not used by the extension resource itself but is required by the AVM interfaces module.
DESCRIPTION
  type        = string
}

variable "extension_type" {
  description = <<DESCRIPTION
Type of the Extension, of which this resource is an instance of. It must be one of the Extension Types registered with Microsoft.KubernetesConfiguration by the Extension publisher.
DESCRIPTION
  type        = string
  default     = null
}

variable "auto_upgrade_minor_version" {
  description = <<DESCRIPTION
Flag to note if this extension participates in auto upgrade of minor version, or not.
DESCRIPTION
  type        = bool
  default     = null
}

variable "extension_version" {
  description = <<DESCRIPTION
User-specified version of the extension for this extension to 'pin'. To use 'extension_version', auto_upgrade_minor_version must be 'false'.
DESCRIPTION
  type        = string
  default     = null
}

variable "release_train" {
  description = <<DESCRIPTION
ReleaseTrain this extension participates in for auto-upgrade (e.g. Stable, Preview, etc.) - only if auto_upgrade_minor_version is 'true'.
DESCRIPTION
  type        = string
  default     = null
}

variable "scope" {
  description = <<DESCRIPTION
Scope at which the extension is installed.

- `cluster` - Specifies that the scope of the extension is Cluster
  - `release_namespace` - Namespace where the extension Release must be placed, for a Cluster scoped extension.  If this namespace does not exist, it will be created
- `namespace` - Specifies that the scope of the extension is Namespace
  - `target_namespace` - Namespace where the extension will be created for a Namespace scoped extension.  If this namespace does not exist, it will be created

DESCRIPTION
  type = object({
    cluster = optional(object({
      release_namespace = optional(string)
    }))
    namespace = optional(object({
      target_namespace = optional(string)
    }))
  })
  default = null
}

variable "configuration_settings" {
  description = <<DESCRIPTION
Configuration settings, as name-value pairs for configuring this extension.
DESCRIPTION
  type        = map(string)
  default     = null
}

variable "configuration_protected_settings" {
  description = <<DESCRIPTION
Configuration settings that are sensitive, as name-value pairs for configuring this extension.
These values are passed via sensitive_body and will not appear in plan output.
DESCRIPTION
  type        = map(string)
  default     = null
  sensitive   = true
}

variable "aks_assigned_identity" {
  description = <<DESCRIPTION
Identity of the Extension resource in an AKS cluster.

- `type` - The identity type. Possible values are `SystemAssigned` and `UserAssigned`.

DESCRIPTION
  type = object({
    type = optional(string)
  })
  default = null

  validation {
    condition     = var.aks_assigned_identity == null || var.aks_assigned_identity.type == null || contains(["SystemAssigned", "UserAssigned"], var.aks_assigned_identity.type)
    error_message = "aks_assigned_identity.type must be one of: \"SystemAssigned\", \"UserAssigned\"."
  }
}

variable "plan" {
  description = <<DESCRIPTION
Details of the resource plan for marketplace extensions.

- `name` - A user defined name of the 3rd Party Artifact that is being procured.
- `product` - The 3rd Party artifact that is being procured. E.g. NewRelic. Product maps to the OfferID specified for the artifact at the time of Data Market onboarding.
- `publisher` - The publisher of the 3rd Party Artifact that is being bought. E.g. NewRelic
- `promotion_code` - A publisher provided promotion code as provisioned in Data Market for the said product/artifact.
- `version` - The version of the desired product/artifact.

DESCRIPTION
  type = object({
    name           = string
    product        = string
    publisher      = string
    promotion_code = optional(string)
    version        = optional(string)
  })
  default = null
}

variable "statuses" {
  description = <<DESCRIPTION
Status from this extension.

- `code` - Status code provided by the Extension.
- `display_status` - Short description of status of the extension.
- `level` - Level of the status. Possible values are `Information`, `Warning`, and `Error`. Defaults to `Information` if not specified.
- `message` - Detailed message of the status from the Extension.
- `time` - DateLiteral (per ISO8601) noting the time of installation status.

DESCRIPTION
  type = list(object({
    code           = optional(string)
    display_status = optional(string)
    level          = optional(string, "Information")
    message        = optional(string)
    time           = optional(string)
  }))
  default = null

  validation {
    condition = var.statuses == null || alltrue([
      for s in var.statuses : s.level == null || contains(["Information", "Warning", "Error"], s.level)
    ])
    error_message = "statuses[].level must be one of: \"Information\", \"Warning\", \"Error\"."
  }
}

# tflint-ignore: terraform_unused_declarations
variable "managed_identities" {
  description = <<DESCRIPTION
Controls the Managed Identity configuration on this resource. Extensions only support SystemAssigned identity.

- `system_assigned` - (Optional) Specifies whether the System Assigned Managed Identity should be enabled. Defaults to `false`.

DESCRIPTION
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default  = {}
  nullable = false
}

variable "enable_telemetry" {
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module. For more information see https://aka.ms/avm/telemetryinfo.
DESCRIPTION
  type        = bool
  default     = true
  nullable    = false
}
