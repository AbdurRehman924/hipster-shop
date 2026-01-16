#!/bin/bash
set -e

echo "💰 Deploying Kubecost..."

# Add Kubecost Helm repo
helm repo add kubecost https://kubecost.github.io/cost-analyzer/
helm repo update

# Install Kubecost
echo "📦 Installing Kubecost..."
helm upgrade --install kubecost kubecost/cost-analyzer \
    --namespace kubecost \
    --create-namespace \
    --values k8s/helm/kubecost/values.yaml \
    --wait

echo "⏳ Waiting for Kubecost to be ready..."
kubectl wait --for=condition=Ready pods --all -n kubecost --timeout=300s

echo "✅ Kubecost deployed successfully!"
echo ""
echo "💵 Access Kubecost Dashboard:"
echo "kubectl port-forward -n kubecost svc/kubecost-cost-analyzer 9090:9090"
echo "Then visit: http://localhost:9090"
echo ""
echo "📊 Key features:"
echo "- Real-time cost allocation by namespace, deployment, service"
echo "- Resource efficiency recommendations"
echo "- Cost forecasting and budgets"
echo "- Idle resource detection"
echo ""
echo "🔍 View cost breakdown:"
echo "kubectl port-forward -n kubecost svc/kubecost-cost-analyzer 9090:9090"
