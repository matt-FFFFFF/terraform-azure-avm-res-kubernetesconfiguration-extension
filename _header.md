# terraform-azure-avm-res-kubernetesconfiguration-extension

This module deploys a Kubernetes Configuration Extension (`Microsoft.KubernetesConfiguration/extensions`) on a Kubernetes cluster (AKS or Arc-enabled).

Extensions enable additional functionality on Kubernetes clusters, such as Flux for GitOps, Azure Monitor, Azure Key Vault Secrets Provider, and other marketplace extensions.

## Features

- Deploy Kubernetes extensions on AKS managed clusters or Arc-enabled Kubernetes clusters
- Support for extension pinning to a specific version or auto-upgrade via release trains
- Cluster-scoped and namespace-scoped extensions
- Configuration settings and sensitive configuration settings (protected via `sensitive_body`)
- System-assigned managed identity support
- Marketplace extension support with plan details
- AKS assigned identity configuration
