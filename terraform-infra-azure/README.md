# Azure Infrastructure Deployment

## Prerequisites

1. **Azure CLI** installed and authenticated:
```bash
az login
az account set --subscription <subscription-id>
```

2. **Terraform** installed (v1.0+)

## Deployment Steps

### 1. Configure Variables
```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
# Note: acr_name must be globally unique and alphanumeric only
```

### 2. Initialize Terraform
```bash
terraform init
```

### 3. Deploy Infrastructure
```bash
terraform plan
terraform apply
```

### 4. Get Cluster Credentials
```bash
az aks get-credentials --resource-group hipster-shop-rg --name hipster-shop-aks
```

### 5. Verify Connection
```bash
kubectl get nodes
```

## Resource Mapping (DOKS → AKS)

| DigitalOcean | Azure | Notes |
|--------------|-------|-------|
| DOKS Cluster | AKS | 3 nodes, Standard_B2s (2 vCPU, 4GB RAM) |
| DO Container Registry | Azure Container Registry | Basic tier |
| s-2vcpu-4gb | Standard_B2s | Equivalent VM size |
| sgp1 region | Southeast Asia | Similar geographic location |

## Cost Estimate

- **AKS**: ~$70-80/month (3 x Standard_B2s nodes)
- **ACR**: ~$5/month (Basic tier)
- **Total**: ~$75-85/month

## Cleanup

```bash
terraform destroy
```
