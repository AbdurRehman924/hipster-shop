# Kubecost Guide

Understand and optimize Kubernetes costs.

## 🎯 What You'll Learn

- **Cost Allocation**: Per namespace, deployment, pod
- **Resource Efficiency**: Identify waste and over-provisioning
- **Forecasting**: Predict future costs
- **Optimization**: Right-sizing recommendations

## 🚀 Quick Start

```bash
# Deploy Kubecost
./scripts/deploy-kubecost.sh

# Access dashboard
kubectl port-forward -n kubecost svc/kubecost-cost-analyzer 9090:9090
# Visit: http://localhost:9090
```

## 💰 Key Features

### Cost Allocation
- View costs by namespace, deployment, service, label
- Understand which services cost the most
- Track cost trends over time

### Efficiency Metrics
- **Idle Costs**: Resources allocated but not used
- **Over-Provisioning**: Requested vs actual usage
- **Right-Sizing**: Recommendations to optimize

### Savings Opportunities
- Identify idle resources
- Spot over-provisioned workloads
- Recommend node type changes

## 📊 Cost Analysis

### By Namespace
```bash
# View in dashboard: Allocations > Namespace
# Shows: hipster-shop, monitoring, istio-system costs
```

### By Service
```bash
# View in dashboard: Allocations > Deployment
# Identify most expensive microservices
```

### Idle Resources
```bash
# View in dashboard: Savings > Idle Resources
# Find pods with low utilization
```

## 🔧 Optimization Actions

### 1. Right-Size Pods
Based on Kubecost recommendations:
```yaml
# Before
resources:
  requests:
    cpu: 500m
    memory: 512Mi

# After (optimized)
resources:
  requests:
    cpu: 100m
    memory: 128Mi
```

### 2. Remove Idle Resources
```bash
# Find idle deployments
# Scale down or remove unused services
kubectl scale deployment <name> --replicas=0 -n hipster-shop
```

### 3. Use Spot Instances
- Configure node pools with spot instances
- Save 60-80% on compute costs
- Suitable for fault-tolerant workloads

## 📈 Cost Monitoring

### Set Budgets
1. Go to Savings > Budgets
2. Set monthly budget per namespace
3. Configure alerts for overruns

### Track Trends
- Daily/weekly/monthly cost trends
- Compare periods
- Identify cost spikes

## 🎓 Best Practices

1. **Review Weekly**: Check cost reports regularly
2. **Set Alerts**: Budget alerts for cost overruns
3. **Right-Size**: Apply VPA recommendations
4. **Clean Up**: Remove unused resources
5. **Use Spot**: For non-critical workloads

## 💡 Cost Optimization Tips

- Use HPA to scale down during low traffic
- Implement pod disruption budgets
- Use cluster autoscaler for node efficiency
- Archive old logs and metrics
- Use smaller node types where possible
