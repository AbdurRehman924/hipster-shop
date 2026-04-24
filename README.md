# Hipster Shop - Cloud-Native Environment

A hands-on Kubernetes environment built around Google's [Online Boutique](https://github.com/GoogleCloudPlatform/microservices-demo) (hipster-shop) microservices demo app. The project covers production-grade cloud-native tooling across 15 phases using real manifests, Terraform infrastructure, and GitOps workflows.

---

## Project Structure

```
hipster-shop/
├── terraform-infra-azure/        # AKS cluster + Azure Container Registry
├── terraform-infra-digitalocean/ # DOKS cluster + DO Container Registry
├── k8s/
│   ├── applications/hipster-shop/ # Microservice manifests (11 services)
│   ├── monitoring/               # Prometheus + Alertmanager
│   ├── logging/                  # Loki + Promtail
│   ├── service-mesh/             # Istio + traffic management
│   ├── security/                 # Falco, Trivy, Network Policies
│   ├── autoscaling/              # HPA, VPA, PDB
│   ├── backup/                   # Velero
│   ├── tracing/                  # Jaeger
│   └── gitops/                   # ArgoCD app manifest
├── gitops/applications/          # ArgoCD Application CRDs
├── scripts/
│   └── verify-platform.sh        # Full platform health check
├── docs/
│   ├── LEARNING-PROGRESS.md      # Phase-by-phase progress tracker
│   └── PRACTICAL-SCENARIOS.md    # Real-world scenario walkthroughs
└── Makefile                      # Common workflow shortcuts
```

---

## Infrastructure

Two cloud providers are supported — pick one:

### DigitalOcean (DOKS)
```bash
cd terraform-infra-digitalocean
cp terraform.tfvars.example terraform.tfvars  # add DO token + project name
terraform init && terraform apply
doctl kubernetes cluster kubeconfig save hipster-shop
```
- 3-node cluster: `s-2vcpu-4gb` (~$36/month)
- Basic Container Registry included

### Azure (AKS)
```bash
cd terraform-infra-azure
cp terraform.tfvars.example terraform.tfvars  # set acr_name (globally unique)
terraform init && terraform apply
az aks get-credentials --resource-group HIPSTER-SHOP --name hipster-shop-aks
```
- 3-node cluster: `Standard_B2s` (~$75-85/month)
- Basic Azure Container Registry included

---

## Application

The hipster-shop app consists of 11 microservices deployed to the `hipster-shop` namespace:

| Service | Language |
|---|---|
| frontend | Go |
| cartservice | C# |
| productcatalogservice | Go |
| currencyservice | Node.js |
| paymentservice | Node.js |
| shippingservice | Go |
| emailservice | Python |
| checkoutservice | Go |
| recommendationservice | Python |
| adservice | Java |
| loadgenerator | Python/Locust |

---

## Phases

| Phase | Topic | K8s Area |
|---|---|---|
| 1 | Foundation & Infrastructure | Cluster setup, namespaces |
| 2 | Observability & Monitoring | Prometheus, Grafana |
| 3 | Security & Compliance | Falco, Trivy, Network Policies |
| 4 | Service Mesh & Networking | Istio, mTLS, traffic management |
| 5 | GitOps & Automation | ArgoCD |
| 6 | Centralized Logging | Loki, Promtail |
| 7 | Autoscaling & Performance | HPA, VPA, PDB |
| 8 | Advanced Traffic Management | Canary, A/B, circuit breaker |
| 9 | Backup & Disaster Recovery | Velero |
| 10 | Chaos Engineering | Chaos Mesh |
| 11 | Cost Optimization | Kubecost |
| 12 | Advanced Security | OPA, Pod Security Standards |
| 13 | Multi-Environment Setup | Kustomize overlays |
| 14 | Distributed Tracing | Jaeger |
| 15 | CI/CD Integration | GitHub Actions |

See `docs/LEARNING-PROGRESS.md` for detailed task breakdowns and `docs/PRACTICAL-SCENARIOS.md` for scenario-based exercises.

---

## Quick Commands

```bash
make help            # list all available targets
make status          # check cluster + pod health
make health          # kubectl get pods --all-namespaces
make clean-namespaces  # delete monitoring/istio/argocd/logging namespaces
make destroy-all     # terraform destroy (full teardown)
```

```bash
# Verify full platform
./scripts/verify-platform.sh

# Apply a specific layer
kubectl apply -R -f k8s/monitoring/
kubectl apply -R -f k8s/service-mesh/
kubectl apply -R -f k8s/security/
```

---

## GitOps (ArgoCD)

ArgoCD Application CRDs live in `gitops/applications/`. Each file points to a subdirectory in `k8s/` as its source:

- `hipster-shop.yaml` → `k8s/applications/hipster-shop`
- `monitoring.yaml` → `k8s/monitoring`
- `logging.yaml` → `k8s/logging`
- `service-mesh.yaml` → `k8s/service-mesh`
- `security.yaml` → `k8s/security`
- `autoscaling.yaml` → `k8s/autoscaling`
- `tracing.yaml` → `k8s/tracing`

Install ArgoCD, then apply the apps:
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f gitops/applications/
```
