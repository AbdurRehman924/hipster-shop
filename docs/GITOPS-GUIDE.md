# GitOps with ArgoCD Guide

Learn continuous deployment with GitOps principles.

## 🎯 What You'll Learn

- **Declarative Deployments**: Git as single source of truth
- **Automated Sync**: Continuous deployment from Git
- **Multi-Environment**: Dev/staging/prod workflows
- **Rollback**: Easy revert to previous versions
- **Image Updates**: Automated image version updates

## 🚀 Quick Start

```bash
# Deploy ArgoCD
./scripts/deploy-argocd.sh

# Generate GitOps manifests
./scripts/generate-gitops-manifests.sh

# Access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Visit: https://localhost:8080
```

## 📁 Repository Structure

```
gitops/
├── applications/          # ArgoCD app definitions
├── environments/         # Environment overlays
│   ├── dev/             # Development config
│   ├── staging/         # Staging config
│   └── prod/            # Production config
└── base/                # Base configurations
```

## 🔄 GitOps Workflow

1. **Developer commits** code changes to Git
2. **ArgoCD detects** changes in Git repository
3. **ArgoCD syncs** changes to Kubernetes cluster
4. **Applications update** automatically
5. **Monitoring alerts** on deployment issues

## 🎯 Key Benefits

### With External Images (like Google's demo)
- ✅ **No CI/CD pipeline needed** for images
- ✅ **Focus on configuration management**
- ✅ **Learn GitOps principles** without complexity
- ✅ **Version control** all Kubernetes configs
- ✅ **Easy rollbacks** via Git history

### Production Advantages
- **Audit Trail**: All changes tracked in Git
- **Consistency**: Same deployment process everywhere
- **Security**: No kubectl access needed
- **Collaboration**: Code review for infrastructure

## 🧪 Testing GitOps

```bash
# Make a change to replicas
git checkout -b test-scaling
sed -i 's/replicas: 2/replicas: 3/' gitops/environments/dev/kustomization.yaml
git commit -am "Scale frontend to 3 replicas"
git push origin test-scaling

# ArgoCD will detect and apply changes automatically
# Watch in ArgoCD UI or:
kubectl get pods -n hipster-shop -w
```

## 🔧 Advanced Features

### Image Updates
```yaml
# Add to Application metadata
annotations:
  argocd-image-updater.argoproj.io/image-list: frontend=gcr.io/google-samples/microservices-demo/frontend
  argocd-image-updater.argoproj.io/write-back-method: git
```

### Multi-Environment Promotion
```bash
# Promote from dev to staging
git checkout staging
git merge dev
git push origin staging
# ArgoCD syncs staging environment
```

## 📊 Monitoring GitOps

- **ArgoCD UI**: Visual deployment status
- **Slack/Teams**: Integration for notifications
- **Prometheus**: ArgoCD metrics
- **Grafana**: GitOps dashboards

## 🎓 Best Practices

1. **Separate repos**: App code vs config code
2. **Environment branches**: dev/staging/prod branches
3. **Automated testing**: Validate configs before merge
4. **Security scanning**: Scan manifests for issues
5. **Backup**: Regular ArgoCD configuration backup
