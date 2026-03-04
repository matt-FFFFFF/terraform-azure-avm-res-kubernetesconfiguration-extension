# tfmodmake - Creating a New AVM Module

CLI tool for generating Terraform AVM modules from Azure resource type definitions. It scaffolds the base module, child submodules, and AVM interface files using the Azure bicep types packages and REST API specs.

Source: <https://github.com/matt-FFFFFF/tfmodmake>

## Installation

Download the latest release from GitHub:

```bash
# Linux (amd64)
curl -sSfL https://github.com/matt-FFFFFF/tfmodmake/releases/latest/download/tfmodmake_linux_amd64.tar.gz | tar -xz -C /usr/local/bin tfmodmake

# macOS (Apple Silicon)
curl -sSfL https://github.com/matt-FFFFFF/tfmodmake/releases/latest/download/tfmodmake_darwin_arm64.tar.gz | tar -xz -C /usr/local/bin tfmodmake

# macOS (Intel)
curl -sSfL https://github.com/matt-FFFFFF/tfmodmake/releases/latest/download/tfmodmake_darwin_amd64.tar.gz | tar -xz -C /usr/local/bin tfmodmake
```

Or install with Go:

```bash
go install github.com/matt-FFFFFF/tfmodmake@latest
```

Check latest version at: <https://github.com/matt-FFFFFF/tfmodmake/releases>

## Workflow Overview

1. Discover resource types and API versions
2. Generate the module with `tfmodmake gen avm`
3. Review and fix generated code (see [Common Issues](#common-issues-and-required-fixes))
4. Create a test example
5. Run pre-commit checks

## Step 1: Discover Resources

### List available API versions for a resource type

```bash
tfmodmake discover versions --resource "Microsoft.ContainerService/managedClusters"
```

### List child resource types

```bash
tfmodmake discover children --parent "Microsoft.ContainerService/managedClusters"
tfmodmake discover children --parent "Microsoft.ContainerService/managedClusters" --json
```

## Step 2: Generate the Module

### Generate a full AVM module (base + child submodules + AVM interfaces)

This is the primary command for creating a new AVM module from scratch. Run this from the root of the module repository:

```bash
tfmodmake gen avm --resource "Microsoft.ContainerService/managedClusters" --api-version "2025-10-01"
```

### Options

| Flag                | Description                                                               |
| ------------------- | ------------------------------------------------------------------------- |
| `--resource`        | Parent resource type (e.g., `Microsoft.ContainerService/managedClusters`) |
| `--api-version`     | Pin to a specific API version (otherwise uses latest stable)              |
| `--include-preview` | Use latest preview API version if newer than stable                       |
| `--local-name`      | Override the local variable name (default: `resource_body`)               |
| `--module-dir`      | Directory for child modules (default: `modules`)                          |
| `--dry-run`         | Print planned actions without writing files                               |

### Example: generate with a specific API version

```bash
tfmodmake gen avm --resource "Microsoft.Network/virtualNetworks" --api-version "2024-01-01"
```

### Example: include preview API versions

```bash
tfmodmake gen avm --resource "Microsoft.KubernetesConfiguration/extensions" --include-preview
```

### Example: dry run first to see what will be generated

```bash
tfmodmake gen avm --resource "Microsoft.ContainerService/managedClusters" --dry-run
```

## Step 3: Add Components Individually (Optional)

If you need to add a child submodule or AVM interfaces after initial generation:

### Add a child submodule

```bash
tfmodmake gen submodule --child "Microsoft.ContainerService/managedClusters/agentPools"
```

| Flag                | Description                                      |
| ------------------- | ------------------------------------------------ |
| `--child`           | Child resource type to generate                  |
| `--api-version`     | Pin to a specific API version                    |
| `--include-preview` | Use latest preview API version                   |
| `--module-dir`      | Directory for child modules (default: `modules`) |
| `--module-name`     | Override derived module folder name              |
| `--dry-run`         | Print planned actions without writing files      |

### Add AVM interface files

```bash
tfmodmake add avm-interfaces
```

## Common Issues and Required Fixes

The generated code is a starting point, not a finished module. The bicep types packages and Azure REST API specs have imperfections that require manual review and correction. The following issues are commonly encountered and MUST be addressed before the module is usable.

### 1. Read-only properties generated as input variables

The generator may create input variables for properties that are read-only (set by Azure, not by the user). These must be removed from `variables.tf` and any references in `main.tf` / locals.

**How to identify them**: Look for variables representing properties like:

- `provisioning_state` / `provisioningState`
- `status`
- `creation_time` / `createdAt` / `created_by`
- `modified_time` / `lastModifiedAt` / `last_modified_by`
- `id` (the resource ID, not a user-supplied identifier)
- `type` (the ARM resource type)
- `system_data`
- `etag` (in most cases)

**Action**: Remove these variables and their references. Use judgement -- if a property is clearly output-only metadata, it should not be an input variable. If unsure, check the Azure REST API documentation for the resource type to confirm whether the property is read-only.

### 2. Reserved variable names

Terraform has reserved names that cannot be used as variable names. The generator may produce variables with these names.

**Common conflicts**:

- `count` -- rename to something like `instance_count` or `replica_count`
- `version` -- rename to something like `api_version`, `runtime_version`, or `<resource>_version`
- `for_each` -- rename to describe the collection
- `source` -- rename to describe the source type
- `depends_on` -- rename to describe the dependency
- `providers` -- rename to describe the provider set
- `lifecycle` -- rename to describe the lifecycle configuration

**Action**: Rename the variable and update all references in `main.tf`, locals, and any submodules.

### 3. parent_id variable needs validation

The generated `parent_id` variable typically lacks proper validation. Add a validation block that enforces the correct parent scope for the resource type.

**For resources scoped to a resource group**:

```hcl
variable "parent_id" {
  type        = string
  description = "The resource ID of the resource group in which to create the resource."

  validation {
    condition     = can(regex("^/subscriptions/[a-f0-9-]+/resourceGroups/[a-zA-Z0-9._()-]+$", var.parent_id))
    error_message = "parent_id must be a valid resource group ID, e.g. /subscriptions/{sub-id}/resourceGroups/{rg-name}"
  }
}
```

**For resources scoped to a parent resource** (e.g., a child resource of a virtual network):

```hcl
variable "parent_id" {
  type        = string
  description = "The resource ID of the parent resource."

  validation {
    condition     = can(regex("^/subscriptions/[a-f0-9-]+/resourceGroups/[^/]+/providers/Microsoft\\.[^/]+/[^/]+/[^/]+$", var.parent_id))
    error_message = "parent_id must be a valid Azure resource ID."
  }
}
```

**For resources scoped to a subscription**:

```hcl
variable "parent_id" {
  type        = string
  description = "The resource ID of the subscription."

  validation {
    condition     = can(regex("^/subscriptions/[a-f0-9-]+$", var.parent_id))
    error_message = "parent_id must be a valid subscription ID, e.g. /subscriptions/{sub-id}"
  }
}
```

Adjust the description, regex, and error message to match the specific resource type's parent scope.

### 4. Create a test example

After fixing the generated code, create an example to validate the module works end-to-end. Create an `examples/default` directory with a basic deployment:

```
examples/
  default/
    main.tf
    variables.tf
    outputs.tf
    terraform.tf
```

The example should:

- Deploy the module with minimal required inputs
- Use realistic but simple values
- Include any prerequisite resources (e.g., resource group, parent resources)
- Use the AzAPI provider for any prerequisite infrastructure

Test the example:

```bash
PORCH_NO_TUI=1 AVM_EXAMPLE="default" ./avm test-examples
```

## Next steps

NOW RETURN TO THE PARENT SKILL TO COMPLETE THE PROCESS

## References

- [tfmodmake GitHub repository](https://github.com/matt-FFFFFF/tfmodmake)
- [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/)
- [AzAPI Provider](https://registry.terraform.io/providers/Azure/azapi/latest/docs)
