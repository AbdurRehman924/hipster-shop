# Migration Guide: DigitalOcean → Azure

## Overview
This guide walks you through migrating the Hipster Shop project from DigitalOcean Kubernetes (DOKS) to Azure Kubernetes Service (AKS).

## Prerequisites

- Azure CLI installed
- Azure subscription with appropriate permissions
- Terraform installed
- kubectl installed

## Step-by-Step Migration

### 1. Authenticate with Azure
```bash
az login
az account list --output table
az account set --subscription <subscription-id>
```

### 2. Configure Azure Infrastructure
```bash
cd terraform-infra-azure
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:
```hcl
location            = "Southeast Asia"  # or your preferred region
resource_group_name = "hipster-shop-rg"
acr_name           = "hipstershopacr123"  # must be globally unique, alphanumeric only
```

### 3. Deploy Azure Infrastructure
```bash
terraform init
terraform plan
terraform apply
```

### 4. Get AKS Credentials
```bash
az aks get-credentials --resource-group hipster-shop-rg --name hipster-shop-aks
kubectl config current-context
kubectl get nodes
```

### 5. Update Application Configurations

No changes needed for most Kubernetes manifests. The application is cloud-agnostic.

### 6. Deploy Applications
```bash
cd ..
make deploy  # Uses existing Makefile commands
```

## Key Differences

### Infrastructure
| Component | DigitalOcean | Azure |
|-----------|--------------|-------|
| Cluster | DOKS | AKS |
| Registry | DO Container Registry | Azure Container Registry (ACR) |
| Node Size | s-2vcpu-4gb | Standard_B2s (2 vCPU, 4GB) |
| Region | sgp1 | Southeast Asia |
| Networking | DO VPC | Azure CNI |

### Commands
| Task | DigitalOcean | Azure |
|------|--------------|-------|
| Get credentials | `doctl kubernetes cluster kubeconfig save` | `az aks get-credentials` |
| Registry login | `doctl registry login` | `az acr login` |
| View cluster | `doctl kubernetes cluster list` | `az aks list` |

### Storage Classes
- **DOKS**: `do-block-storage` (default)
- **AKS**: `managed-csi` (default)

Update PVCs if you explicitly specified storage class:
```yaml
storageClassName: managed-csi  # Changed from do-block-storage
```

### Load Balancers
- **DOKS**: DigitalOcean Load Balancer
- **AKS**: Azure Load Balancer

No configuration changes needed - both support standard Kubernetes LoadBalancer services.

## Cost Comparison

### DigitalOcean
- 3 x s-2vcpu-4gb nodes: ~$72/month
- Container Registry (Basic): Included
- **Total**: ~$72/month

### Azure
- 3 x Standard_B2s nodes: ~$70-80/month
- ACR (Basic): ~$5/month
- **Total**: ~$75-85/month

## Rollback Plan

If you need to rollback to DigitalOcean:

```bash
# Switch kubectl context back to DOKS
kubectl config use-context do-sgp1-hipster-shop

# Or get fresh credentials
doctl kubernetes cluster kubeconfig save hipster-shop

# Destroy Azure resources
cd terraform-infra-azure
terraform destroy
```

## Verification Checklist

After migration, verify:

- [ ] All nodes are Ready: `kubectl get nodes`
- [ ] All pods are Running: `kubectl get pods -A`
- [ ] Services have external IPs: `kubectl get svc -A`
- [ ] ACR integration works: `kubectl describe pod <pod-name> | grep -i image`
- [ ] Storage provisioning works: `kubectl get pvc -A`
- [ ] Monitoring stack accessible
- [ ] Application accessible via LoadBalancer

## Troubleshooting

### ACR Pull Errors
```bash
# Verify AKS has ACR pull permissions
az role assignment list --assignee <aks-kubelet-identity> --scope <acr-id>

# Manually attach ACR if needed
az aks update -n hipster-shop-aks -g hipster-shop-rg --attach-acr hipstershopacr
```

### Node Not Ready
```bash
kubectl describe node <node-name>
az aks show -n hipster-shop-aks -g hipster-shop-rg
```

### Storage Issues
```bash
kubectl get storageclass
kubectl describe pvc <pvc-name>
```

## Next Steps

Once migration is complete:
1. Update documentation references from DOKS to AKS
2. Update CI/CD pipelines if any
3. Test all 15 learning phases work on AKS
4. Update backup configurations for Azure Blob Storage (if using Velero)

## Support

For Azure-specific issues:
- Azure Docs: https://docs.microsoft.com/azure/aks/
- AKS Troubleshooting: https://docs.microsoft.com/azure/aks/troubleshooting
