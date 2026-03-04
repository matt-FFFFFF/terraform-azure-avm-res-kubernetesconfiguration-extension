locals {
  resource_body = {
    plan = var.plan == null ? null : {
      name          = var.plan.name
      product       = var.plan.product
      promotionCode = var.plan.promotion_code
      publisher     = var.plan.publisher
      version       = var.plan.version
    }
    properties = {
      aksAssignedIdentity = var.aks_assigned_identity == null ? null : {
        type = var.aks_assigned_identity.type
      }
      autoUpgradeMinorVersion = var.auto_upgrade_minor_version
      configurationSettings   = var.configuration_settings
      extensionType           = var.extension_type
      releaseTrain            = var.release_train
      scope = var.scope == null ? null : {
        cluster = var.scope.cluster == null ? null : {
          releaseNamespace = var.scope.cluster.release_namespace
        }
        namespace = var.scope.namespace == null ? null : {
          targetNamespace = var.scope.namespace.target_namespace
        }
      }
      statuses = var.statuses == null ? null : [for item in var.statuses : {
        code          = item.code
        displayStatus = item.display_status
        level         = item.level
        message       = item.message
        time          = item.time
      }]
      version = var.extension_version
    }
  }

  # Build the sensitive body for configuration_protected_settings
  sensitive_body = var.configuration_protected_settings == null ? null : {
    properties = {
      configurationProtectedSettings = var.configuration_protected_settings
    }
  }

  # Track which sensitive properties are set so Terraform can detect changes
  sensitive_body_version = var.configuration_protected_settings == null ? {} : {
    for k, _ in var.configuration_protected_settings : "properties.configurationProtectedSettings.${k}" => "1"
  }

  managed_identities = {
    system_assigned = var.managed_identities.system_assigned ? {
      this = {
        type = "SystemAssigned"
      }
    } : {}
  }
}
