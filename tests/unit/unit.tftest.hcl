# tests/unit/unit.tftest.hcl

mock_provider "azapi" {
  mock_resource "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ContainerService/managedClusters/aks-test/providers/Microsoft.KubernetesConfiguration/extensions/test-extension"
    }
  }
}
mock_provider "modtm" {}
mock_provider "random" {}

variables {
  name      = "test-extension"
  parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ContainerService/managedClusters/aks-test"
  location  = "eastus"
}

run "apply_minimal" {
  command = apply

  assert {
    condition     = azapi_resource.this.name == "test-extension"
    error_message = "Extension name should be 'test-extension'."
  }

  assert {
    condition     = azapi_resource.this.parent_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ContainerService/managedClusters/aks-test"
    error_message = "Extension parent_id should match the provided cluster ID."
  }

  assert {
    condition     = output.resource_id != ""
    error_message = "Resource ID output should not be empty."
  }

  assert {
    condition     = output.name == "test-extension"
    error_message = "Name output should be 'test-extension'."
  }
}

run "apply_with_extension_type" {
  command = apply

  variables {
    extension_type             = "microsoft.flux"
    auto_upgrade_minor_version = true
    release_train              = "Stable"
  }

  assert {
    condition     = azapi_resource.this.name == "test-extension"
    error_message = "Extension name should be 'test-extension'."
  }
}

run "apply_with_scope_cluster" {
  command = apply

  variables {
    extension_type = "microsoft.flux"
    scope = {
      cluster = {
        release_namespace = "flux-system"
      }
    }
  }

  assert {
    condition     = azapi_resource.this.name == "test-extension"
    error_message = "Extension should be created with cluster scope."
  }
}

run "apply_with_scope_namespace" {
  command = apply

  variables {
    extension_type = "microsoft.flux"
    scope = {
      namespace = {
        target_namespace = "my-namespace"
      }
    }
  }

  assert {
    condition     = azapi_resource.this.name == "test-extension"
    error_message = "Extension should be created with namespace scope."
  }
}

run "apply_with_configuration_settings" {
  command = apply

  variables {
    extension_type = "microsoft.flux"
    configuration_settings = {
      "helm-controller.enabled" = "true"
    }
  }

  assert {
    condition     = azapi_resource.this.name == "test-extension"
    error_message = "Extension should be created with configuration settings."
  }
}

run "apply_with_system_assigned_identity" {
  command = apply

  variables {
    managed_identities = {
      system_assigned = true
    }
  }

  assert {
    condition     = azapi_resource.this.name == "test-extension"
    error_message = "Extension should be created with system assigned identity."
  }
}

run "apply_with_plan" {
  command = apply

  variables {
    plan = {
      name      = "my-plan"
      product   = "my-product"
      publisher = "my-publisher"
    }
  }

  assert {
    condition     = azapi_resource.this.name == "test-extension"
    error_message = "Extension should be created with a plan."
  }
}

run "apply_with_pinned_version" {
  command = apply

  variables {
    extension_version          = "1.2.3"
    auto_upgrade_minor_version = false
  }

  assert {
    condition     = azapi_resource.this.name == "test-extension"
    error_message = "Extension should be created with a pinned version."
  }
}

run "apply_telemetry_enabled" {
  command = apply

  assert {
    condition     = can(module.avm_interfaces)
    error_message = "AVM interfaces module should be created when enable_telemetry is true (default)."
  }
}

run "test_invalid_parent_id_rejected" {
  command = plan

  variables {
    parent_id = "invalid-id"
  }

  expect_failures = [
    var.parent_id,
  ]
}

run "test_invalid_aks_identity_type_rejected" {
  command = plan

  variables {
    aks_assigned_identity = {
      type = "InvalidType"
    }
  }

  expect_failures = [
    var.aks_assigned_identity,
  ]
}

run "test_invalid_status_level_rejected" {
  command = plan

  variables {
    statuses = [
      {
        level = "InvalidLevel"
      }
    ]
  }

  expect_failures = [
    var.statuses,
  ]
}
