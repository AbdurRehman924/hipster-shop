# 🚀 HIPSTER SHOP - QUICK REFERENCE CARD

## 📍 Access URLs

| Service | URL | Access Method |
|---------|-----|---------------|
| **Application** | http://20.195.103.45 | Direct (Istio Gateway) |
| **Grafana** | http://20.212.91.193 | LoadBalancer (if provisioned) |
| **ArgoCD** | https://localhost:8080 | `kubectl port-forward -n argocd svc/argocd-server 8080:443` |
| **Jaeger** | http://localhost:16686 | `kubectl port-forward -n tracing svc/jaeger-query 16686:80` |
| **Prometheus** | http://localhost:9090 | `kubectl port-forward -n monitoring svc/prometheus 9090:9090` |

## 🔑 Common Commands

### Cluster Access
```bash
# Get cluster credentials
az aks get-credentials --resource-group hipster-shop-rg --name hipster-shop-aks

# View cluster info
kubectl cluster-info
kubectl get nodes
```

### Application Management
```bash
# View all pods
kubectl get pods -n hipster-shop

# Check application status
kubectl get deployments -n hipster-shop

# View logs
kubectl logs -n hipster-shop -l app=frontend --tail=50

# Restart deployment
kubectl rollout restart deployment frontend -n hipster-shop
```

### Monitoring
```bash
# Check Prometheus targets
kubectl port-forward -n monitoring svc/prometheus 9090:9090
# Visit: http://localhost:9090/targets

# Access Grafana
kubectl get svc -n monitoring grafana

# View alerts
kubectl get prometheusrules -n monitoring
```

### Security
```bash
# View Falco alerts
kubectl logs -n security -l app.kubernetes.io/name=falco --tail=100

# Check vulnerability reports
kubectl get vulnerabilityreports -n hipster-shop

# View network policies
kubectl get networkpolicies -n hipster-shop
```

### Service Mesh
```bash
# Check Istio status
kubectl get pods -n istio-system

# View proxies
kubectl get pods -n hipster-shop -o jsonpath='{.items[*].spec.containers[*].name}' | tr ' ' '\n' | grep istio-proxy

# Check mTLS status
istioctl x describe pod <pod-name> -n hipster-shop

# View traffic rules
kubectl get gateway,virtualservice,destinationrule -n hipster-shop
```

### GitOps
```bash
# Access ArgoCD UI
kubectl port-forward -n argocd svc/argocd-server 8080:443

# Get ArgoCD password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Sync application
kubectl patch application hipster-shop -n argocd --type merge -p '{"operation":{"sync":{}}}'
```

### Logging
```bash
# View Loki logs
kubectl logs -n logging -l app=loki --tail=50

# Check Promtail status
kubectl get pods -n logging -l app.kubernetes.io/name=promtail

# Query logs in Grafana
# Use LogQL: {namespace="hipster-shop"} |= "error"
```

### Autoscaling
```bash
# View HPA status
kubectl get hpa -n hipster-shop

# View VPA recommendations
kubectl describe vpa -n hipster-shop

# Check PDB status
kubectl get pdb -n hipster-shop
```

### Backup & Recovery
```bash
# List backups
kubectl get backups -n velero

# Create manual backup
velero backup create manual-backup --include-namespaces hipster-shop

# Restore from backup
velero restore create --from-backup <backup-name>

# View backup schedules
kubectl get schedules -n velero
```

### Distributed Tracing
```bash
# Access Jaeger UI
kubectl port-forward -n tracing svc/jaeger-query 16686:80

# Query traces via API
curl "http://localhost:16686/api/services" | jq -r '.data[]'

# Get traces for a service
curl "http://localhost:16686/api/traces?service=frontend.hipster-shop&limit=10"
```

## 🔧 Troubleshooting

### Pod Not Starting
```bash
# Describe pod
kubectl describe pod <pod-name> -n hipster-shop

# Check events
kubectl get events -n hipster-shop --sort-by='.lastTimestamp'

# View logs
kubectl logs <pod-name> -n hipster-shop --previous
```

### Service Not Accessible
```bash
# Check service
kubectl get svc -n hipster-shop

# Test connectivity
kubectl run test --rm -it --image=busybox -- wget -O- http://frontend.hipster-shop:8080

# Check Istio routing
kubectl get virtualservice,destinationrule -n hipster-shop
```

### High Resource Usage
```bash
# Check node resources
kubectl top nodes

# Check pod resources
kubectl top pods -n hipster-shop

# View resource requests/limits
kubectl describe pod <pod-name> -n hipster-shop | grep -A 5 "Limits\|Requests"
```

### Monitoring Issues
```bash
# Check Prometheus targets
kubectl port-forward -n monitoring svc/prometheus 9090:9090
# Visit: http://localhost:9090/targets

# Verify ServiceMonitors
kubectl get servicemonitors -n monitoring

# Check AlertManager
kubectl logs -n monitoring -l app.kubernetes.io/name=alertmanager
```

## 📊 Key Metrics to Monitor

### Application Health
- Pod status: `kubectl get pods -n hipster-shop`
- Deployment status: `kubectl get deployments -n hipster-shop`
- Service endpoints: `kubectl get endpoints -n hipster-shop`

### Resource Utilization
- Node CPU/Memory: `kubectl top nodes`
- Pod CPU/Memory: `kubectl top pods -n hipster-shop`
- HPA status: `kubectl get hpa -n hipster-shop`

### Observability
- Prometheus targets: Check /targets endpoint
- Grafana dashboards: View "Hipster Shop Monitoring"
- Jaeger traces: Check service list in UI
- Loki logs: Query in Grafana

### Security
- Falco alerts: Check logs for security events
- Trivy reports: `kubectl get vulnerabilityreports -n hipster-shop`
- Network policies: `kubectl get networkpolicies -n hipster-shop`

## 🎯 Quick Health Check

Run the verification script:
```bash
./scripts/verify-platform.sh
```

Or manual check:
```bash
# All namespaces
kubectl get pods --all-namespaces | grep -v Running

# Application
curl -s http://20.195.103.45 -o /dev/null -w "%{http_code}\n"

# Monitoring
kubectl get pods -n monitoring

# Security
kubectl get pods -n security

# Service Mesh
kubectl get pods -n istio-system
```

## 📞 Emergency Procedures

### Application Down
1. Check pod status: `kubectl get pods -n hipster-shop`
2. View recent events: `kubectl get events -n hipster-shop --sort-by='.lastTimestamp'`
3. Check logs: `kubectl logs -n hipster-shop -l app=frontend --tail=100`
4. Restart if needed: `kubectl rollout restart deployment frontend -n hipster-shop`

### High Memory Usage
1. Check metrics: `kubectl top pods -n hipster-shop`
2. View HPA status: `kubectl get hpa -n hipster-shop`
3. Check for memory leaks in logs
4. Scale manually if needed: `kubectl scale deployment <name> --replicas=3 -n hipster-shop`

### Disaster Recovery
1. List backups: `kubectl get backups -n velero`
2. Create restore: `velero restore create --from-backup <backup-name>`
3. Monitor restore: `velero restore describe <restore-name>`
4. Verify: `kubectl get pods -n hipster-shop`

## 📚 Documentation

- **Complete Guide**: `docs/COMPLETE-PROJECT-GUIDE.md`
- **Learning Progress**: `docs/LEARNING-PROGRESS.md`
- **Phase 11 Details**: `docs/PHASE-11-TRACING-SUMMARY.md`
- **Completion Summary**: `docs/PROJECT-COMPLETION-SUMMARY.md`

## 🎉 Quick Wins

### Generate Traffic
```bash
for i in {1..100}; do curl -s http://20.195.103.45 > /dev/null; done
```

### View Traces
```bash
kubectl port-forward -n tracing svc/jaeger-query 16686:80
# Open: http://localhost:16686
```

### Check Autoscaling
```bash
watch kubectl get hpa -n hipster-shop
```

### View Logs
```bash
kubectl logs -n hipster-shop -l app=frontend -f
```

---

**Keep this card handy for quick reference!** 📌
