# Kyverno Policy Enforcement Guide

Automate security and best practices with policy-as-code.

## 🎯 What You'll Learn

- **Validation**: Block non-compliant resources
- **Mutation**: Auto-modify resources to meet standards
- **Generation**: Auto-create supporting resources
- **Policy Reports**: Audit compliance

## 🚀 Quick Start

```bash
# Deploy Kyverno
./scripts/deploy-policies.sh

# Check policies
kubectl get clusterpolicy
```

## 📋 Implemented Policies

### Validation Policies
- **require-resource-limits**: Enforce CPU/memory limits
- **require-pod-requests**: Enforce resource requests
- **disallow-privileged-containers**: Block privileged pods
- **restrict-image-registries**: Allow only approved registries

### Mutation Policies
- **add-default-labels**: Auto-add management labels
- **add-safe-to-evict**: Enable cluster autoscaler eviction

### Audit Policies
- **disallow-latest-tag**: Warn about :latest image tags

## 🧪 Test Policies

```bash
# This will be blocked (no resource limits)
kubectl run test --image=nginx -n hipster-shop

# This will be blocked (privileged)
kubectl run test --image=nginx --privileged -n hipster-shop

# This will work (has limits)
kubectl run test --image=nginx -n hipster-shop \
  --limits=cpu=100m,memory=128Mi \
  --requests=cpu=50m,memory=64Mi
```

## 📊 View Policy Reports

```bash
# Cluster-wide report
kubectl get clusterpolicyreport -A

# Namespace report
kubectl get policyreport -n hipster-shop

# Detailed report
kubectl describe policyreport -n hipster-shop
```

## 🔧 Custom Policies

Create your own policy:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-labels
spec:
  validationFailureAction: enforce
  rules:
  - name: check-labels
    match:
      any:
      - resources:
          kinds:
          - Deployment
    validate:
      message: "Deployments must have 'app' and 'team' labels"
      pattern:
        metadata:
          labels:
            app: "?*"
            team: "?*"
```

## 🎓 Best Practices

1. Start with `audit` mode, then switch to `enforce`
2. Test policies in dev before production
3. Use policy reports for compliance tracking
4. Create exceptions for system namespaces
