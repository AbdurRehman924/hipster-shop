# K8s Directory Structure - Quick Reference

## Current Files (Phase 1-3)

```
k8s/
├── README.md                                    # This file
│
├── monitoring/                                  # Phase 3: Observability
│   ├── prometheus/
│   │   └── values.yaml                         # Prometheus Helm values
│   ├── grafana/                                # (Grafana dashboards - future)
│   └── alertmanager/
│       └── hipster-shop-rules.yaml            # Alert rules for app
│
└── applications/                                # Phase 2: Apps
    └── hipster-shop/                           # (Currently in gitops/base/)
```

## Future Structure (Phases 4-17)

```
k8s/
├── security/                    # Phase 4, 13
│   ├── falco/                  # Runtime security
│   ├── trivy/                  # Vulnerability scanning
│   └── policies/               # Network policies, PSP
│
├── service-mesh/                # Phase 5, 9
│   ├── istio/                  # Service mesh
│   └── virtual-services/       # Traffic management
│
├── gitops/                      # Phase 6
│   └── argocd/                 # GitOps configs
│
├── logging/                     # Phase 7
│   ├── loki/                   # Log aggregation
│   └── promtail/               # Log collection
│
├── autoscaling/                 # Phase 8
│   ├── hpa/                    # Horizontal Pod Autoscaler
│   ├── vpa/                    # Vertical Pod Autoscaler
│   └── cluster-autoscaler/     # Cluster scaling
│
├── backup/                      # Phase 10
│   └── velero/                 # Backup & restore
│
├── chaos/                       # Phase 11
│   └── chaos-mesh/             # Chaos experiments
│
├── tracing/                     # Phase 15
│   └── jaeger/                 # Distributed tracing
│
└── cost/                        # Phase 12
    └── kubecost/               # Cost monitoring
```

## Commands

### Apply monitoring configs:
```bash
# Prometheus (already installed via Helm)
helm upgrade prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values k8s/monitoring/prometheus/values.yaml

# Alert rules
kubectl apply -f k8s/monitoring/alertmanager/hipster-shop-rules.yaml
```

### Future phases:
```bash
# Apply entire category
kubectl apply -R -f k8s/security/

# Apply specific component
kubectl apply -f k8s/logging/loki/
```
