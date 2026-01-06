# Hipster Shop Kubernetes Infrastructure (K8s Native)

Terraform-based infrastructure with Kubernetes-native deployments for Google's Online Boutique microservices demo on DigitalOcean.

## Architecture

- **Infrastructure**: DigitalOcean Kubernetes (DOKS) via Terraform
- **Applications**: Deployed via Helm Charts
- **Storage**: In-memory cart storage (no external database)
- **Separation**: Infrastructure and application deployments are decoupled

## Project Structure

```
├── terraform-infra/          # Infrastructure only (DOKS, Registry)
├── k8s/
│   └── helm/                 # Helm charts
├── scripts/                 # Deployment scripts
└── docs/                    # Documentation
```

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [doctl](https://docs.digitalocean.com/reference/doctl/) (DigitalOcean CLI)
- DigitalOcean API token

Optional:
- [Helm](https://helm.sh/docs/intro/install/) (for Helm deployments)
- [Kustomize](https://kustomize.io/) (for Kustomize deployments)

## Quick Start

1. **Configure variables:**
   ```bash
   cp terraform-infra/terraform.tfvars.example terraform-infra/terraform.tfvars
   # Edit with your DO token
   ```

2. **Deploy everything:**
   ```bash
   ./scripts/deploy.sh
   ```

3. **Or deploy manually:**

   **Infrastructure:**
   ```bash
   cd terraform-infra
   terraform init && terraform apply
   ```

   **Get cluster access:**
   ```bash
   doctl kubernetes cluster kubeconfig save $(terraform output -raw cluster_id)
   ```

   **Deploy apps (choose one):**
   ```bash
   # Helm
   helm install hipster-shop k8s/helm/hipster-shop --create-namespace
   
   # Kustomize
   kubectl apply -k k8s/kustomize/base
   
   # Plain manifests
   kubectl apply -f k8s/manifests/
   ```

## Deployment Options

### 1. Helm Charts
- **Location**: `k8s/helm/hipster-shop/`
- **Features**: Templating, values override, easy upgrades
- **Usage**: `helm install hipster-shop k8s/helm/hipster-shop`

### 2. Kustomize
- **Location**: `k8s/kustomize/`
- **Features**: Overlays for different environments
- **Usage**: `kubectl apply -k k8s/kustomize/base`

### 3. Plain Manifests
- **Location**: `k8s/manifests/`
- **Features**: Simple, direct Kubernetes YAML
- **Usage**: `kubectl apply -f k8s/manifests/`

## Cost Estimation

- DOKS cluster: ~$72/month
- Load balancer: ~$12/month

**Total: ~$84/month**

## Cleanup

```bash
# Remove applications
kubectl delete namespace hipster-shop

# Remove infrastructure
cd terraform-infra && terraform destroy
```
