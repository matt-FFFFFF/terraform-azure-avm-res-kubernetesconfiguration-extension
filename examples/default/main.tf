data "azapi_client_config" "current" {}

locals {
  resource_group_name = "rg-avm-kubernetes-ext-${substr(md5(data.azapi_client_config.current.subscription_id), 0, 8)}"
  cluster_name        = "aks-avm-ext-example"
}

# Create a resource group
resource "azapi_resource" "resource_group" {
  type     = "Microsoft.Resources/resourceGroups@2024-03-01"
  name     = local.resource_group_name
  location = var.location

  body = {}

  response_export_values = []
}

# Create a minimal AKS cluster for the extension
resource "azapi_resource" "aks_cluster" {
  type      = "Microsoft.ContainerService/managedClusters@2024-09-01"
  name      = local.cluster_name
  parent_id = azapi_resource.resource_group.id
  location  = var.location

  identity {
    type = "SystemAssigned"
  }

  body = {
    properties = {
      dnsPrefix = local.cluster_name
      agentPoolProfiles = [
        {
          name         = "system"
          count        = 1
          vmSize       = "Standard_DS2_v2"
          mode         = "System"
          osType       = "Linux"
          osSKU        = "AzureLinux"
          osDiskSizeGB = 30
        }
      ]
    }
  }

  response_export_values = []
}

# Deploy the Kubernetes extension using the module
module "kubernetes_extension" {
  source = "../.."

  name      = "flux"
  parent_id = azapi_resource.aks_cluster.id
  location  = var.location

  extension_type             = "microsoft.flux"
  auto_upgrade_minor_version = true
  release_train              = "Stable"
}
