# Modular Azure Infrastructure

This directory contains modular Terraform configuration for deploying the Hipster Shop infrastructure on Azure.

## Structure

```
terraform-infra-azure/
├── main.tf                    # Root module - orchestrates everything
├── variables.tf               # Root variables
├── outputs.tf                 # Root outputs
├── terraform.tfvars.example   # Example configuration
└── modules/
    ├── resource-group/        # Resource group module
    ├── aks/                   # AKS cluster module
    └── acr/                   # Container registry module
```

## Modules

### resource-group
Creates Azure resource group.

**Inputs:**
- `name` - Resource group name
- `location` - Azure region
- `tags` - Resource tags

### aks
Creates AKS cluster with configurable node pool.

**Inputs:**
- `name` - Cluster name
- `location` - Azure region
- `resource_group_name` - Resource group
- `kubernetes_version` - K8s version (default: 1.34)
- `node_count` - Number of nodes (default: 3)
- `vm_size` - VM size (default: Standard_B2s)

### acr
Creates Azure Container Registry.

**Inputs:**
- `name` - ACR name (globally unique)
- `location` - Azure region
- `resource_group_name` - Resource group
- `sku` - ACR tier (default: Basic)

## Usage

```bash
# Configure
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars

# Deploy
terraform init
terraform plan
terraform apply

# Get credentials
az aks get-credentials --resource-group hipster-shop-rg --name hipster-shop-aks
```

## Benefits of Modular Design

1. **Reusability** - Use modules in other projects
2. **Maintainability** - Changes isolated to modules
3. **Testing** - Test modules independently
4. **Clarity** - Clear separation of concerns
5. **Scalability** - Easy to add new modules
