#!/bin/bash
set -e

echo "📝 Deploying Loki Logging Stack..."

# Add Grafana Helm repo
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Create monitoring namespace if it doesn't exist
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Install Loki stack
echo "🔍 Installing Loki and Promtail..."
helm upgrade --install loki grafana/loki-stack \
    --namespace monitoring \
    --values k8s/helm/logging/values.yaml \
    --wait

# Add Loki datasource to Grafana
echo "📊 Adding Loki datasource to Grafana..."
kubectl apply -f k8s/logging/grafana-datasource.yaml

# Restart Grafana to pick up new datasource
kubectl rollout restart deployment/grafana -n monitoring

echo "✅ Loki logging stack deployed successfully!"
echo ""
echo "📋 Access logs:"
echo "1. Port-forward Grafana: kubectl port-forward svc/grafana 3000:80 -n monitoring"
echo "2. Go to Explore > Select Loki datasource"
echo "3. Query examples:"
echo "   - {namespace=\"hipster-shop\"}"
echo "   - {app=\"frontend\"} |= \"error\""
echo "   - {namespace=\"hipster-shop\"} | json | level=\"ERROR\""
