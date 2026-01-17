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
│   ├── helm/                 # Helm charts
│   │   ├── hipster-shop/     # Main application
│   │   ├── monitoring/       # Observability stack
│   │   ├── logging/          # Loki configuration
│   │   └── kubecost/         # Cost analysis
│   ├── autoscaling/          # HPA/VPA configs
│   ├── chaos/                # Chaos experiments
│   ├── policies/             # Kyverno policies
│   ├── networking/           # Network policies, ingress
│   └── istio/                # Service mesh configuration
├── gitops/                   # GitOps configurations
│   ├── applications/         # ArgoCD app definitions
│   ├── environments/         # Environment overlays (dev/prod)
│   └── base/                 # Base Kustomize configs
├── scripts/                  # Deployment scripts
├── docs/                     # Documentation
│   ├── LEARNING-LAB.md       # Kubernetes learning guide
│   ├── ISTIO-GUIDE.md        # Service mesh learning guide
│   ├── CHAOS-GUIDE.md        # Chaos engineering guide
│   ├── POLICY-GUIDE.md       # Policy enforcement guide
│   ├── KUBECOST-GUIDE.md     # Cost optimization guide
│   └── GITOPS-GUIDE.md       # GitOps workflow guide
└── README.md
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

   **Deploy apps:**
   ```bash
   # Main application
   helm install hipster-shop k8s/helm/hipster-shop --create-namespace
   
   # Monitoring stack (optional)
   ./scripts/deploy-monitoring.sh
   
   # Service mesh (optional)
   ./scripts/deploy-istio.sh
   ```

## 📊 Monitoring & Observability

Complete observability stack with metrics, logs, and autoscaling:

- **Prometheus**: Metrics collection and alerting
- **Grafana**: Visualization and dashboards  
- **Loki**: Log aggregation and querying
- **HPA/VPA**: Automatic scaling based on metrics
- **Custom Dashboards**: Pre-configured for microservices
- **Learning Guide**: Hands-on exercises in `docs/LEARNING-LAB.md`

**Access URLs** (after deployment):
- Grafana: `kubectl port-forward svc/grafana 3000:80 -n monitoring` (admin/admin123)
- Prometheus: `kubectl port-forward svc/prometheus 9090:9090 -n monitoring`

**Autoscaling Commands:**
```bash
# Watch HPA in action
kubectl get hpa -n hipster-shop -w

# Check resource usage
kubectl top pods -n hipster-shop

# View VPA recommendations
kubectl describe vpa -n hipster-shop
```

**Log Queries (in Grafana > Explore > Loki):**
```logql
# All logs from hipster-shop
{namespace="hipster-shop"}

# Frontend errors
{app="frontend"} |= "error"

# JSON log parsing
{namespace="hipster-shop"} | json | level="ERROR"
```

## 🌐 Advanced Networking

Production-grade networking with security and automation:

- **Network Policies**: Zero-trust pod-to-pod communication
- **NGINX Ingress**: Centralized routing with single LoadBalancer
- **Cert-Manager**: Automated TLS certificates from Let's Encrypt
- **External DNS**: Automatic DNS record management
- **Learning Guide**: Hands-on exercises in `docs/NETWORKING-GUIDE.md`

**Features:**
- Secure service-to-service communication
- Automatic HTTPS with certificate renewal
- Cost savings: $24/month (67% reduction in LoadBalancers)
- DNS automation with DigitalOcean integration

## 🕸️ Service Mesh (Istio)

Advanced networking, security, and observability with Istio:

- **Traffic Management**: Canary deployments, circuit breaking
- **Security**: mTLS, authorization policies, zero-trust networking
- **Observability**: Distributed tracing, service topology
- **Learning Guide**: Production scenarios in `docs/ISTIO-GUIDE.md`

**Access URLs** (after Istio deployment):
- Kiali Dashboard: `http://<INGRESS-IP>:20001`
- Jaeger Tracing: `http://<INGRESS-IP>:16686`
- Application: `http://<INGRESS-IP>`

## 🌪️ Chaos Engineering

Test system resilience with Chaos Mesh:

- **Pod Chaos**: Simulate failures, kills, restarts
- **Network Chaos**: Inject latency, packet loss, partitions
- **Stress Testing**: CPU and memory pressure
- **HTTP Chaos**: API failures and delays
- **Learning Guide**: Hands-on experiments in `docs/CHAOS-GUIDE.md`

**Deploy & Access:**
```bash
./scripts/deploy-chaos.sh
kubectl port-forward -n chaos-mesh svc/chaos-dashboard 2333:2333
# Visit: http://localhost:2333
```

## 🔒 Policy Enforcement (Kyverno)

Automate security and compliance with policy-as-code:

- **Validation**: Block non-compliant resources
- **Mutation**: Auto-modify resources to meet standards
- **Security**: Enforce best practices automatically
- **Audit**: Compliance reporting
- **Learning Guide**: Policy examples in `docs/POLICY-GUIDE.md`

**Deploy & Test:**
```bash
./scripts/deploy-policies.sh
kubectl get clusterpolicy
kubectl get policyreport -A
```

## 🔄 GitOps with ArgoCD

Continuous deployment with Git-based workflows:

- **Declarative Deployments**: Git as single source of truth
- **Automated Sync**: Continuous deployment from Git commits
- **Multi-Environment**: Dev/staging/prod promotion workflows
- **Self-Healing**: Automatic drift correction and rollbacks
- **Image Updates**: Automated container version management
- **Learning Guide**: Complete GitOps workflow in `docs/GITOPS-GUIDE.md`

**Deploy & Access:**
```bash
./scripts/deploy-argocd.sh
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Visit: https://localhost:8080 (admin/password from script output)
```

**GitOps Workflow:**
```bash
# Make changes to GitOps configs
git checkout -b feature/scale-frontend
sed -i 's/replicas: 2/replicas: 3/' gitops/environments/dev/kustomization.yaml
git commit -am "Scale frontend to 3 replicas"
git push origin feature/scale-frontend
# ArgoCD automatically detects and applies changes
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
