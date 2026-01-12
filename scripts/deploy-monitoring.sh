#!/bin/bash

echo "🚀 Deploying Monitoring Stack..."

# Deploy monitoring stack
helm upgrade --install monitoring-stack k8s/helm/monitoring --create-namespace

echo "⏳ Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=prometheus -n monitoring --timeout=300s
kubectl wait --for=condition=ready pod -l app=grafana -n monitoring --timeout=300s

echo "📊 Getting service URLs..."
echo ""
echo "Prometheus: http://$(kubectl get svc prometheus -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].ip}'):9090"
echo "Grafana: http://$(kubectl get svc grafana -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].ip}'):3000"
echo "  Username: admin"
echo "  Password: admin123"
echo ""
echo "✅ Monitoring stack deployed successfully!"
echo ""
echo "📚 Learning Resources:"
echo "- Prometheus queries: https://prometheus.io/docs/prometheus/latest/querying/"
echo "- Grafana dashboards: https://grafana.com/docs/grafana/latest/dashboards/"
echo "- Kubernetes monitoring: https://kubernetes.io/docs/tasks/debug-application-cluster/resource-usage-monitoring/"
