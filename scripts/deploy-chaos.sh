#!/bin/bash
set -e

echo "🌪️  Deploying Chaos Mesh..."

# Add Chaos Mesh Helm repo
helm repo add chaos-mesh https://charts.chaos-mesh.org
helm repo update

# Install Chaos Mesh
echo "📦 Installing Chaos Mesh..."
helm upgrade --install chaos-mesh chaos-mesh/chaos-mesh \
    --namespace chaos-mesh \
    --create-namespace \
    --set chaosDaemon.runtime=containerd \
    --set chaosDaemon.socketPath=/run/containerd/containerd.sock \
    --set dashboard.create=true \
    --wait

echo "⏳ Waiting for Chaos Mesh to be ready..."
kubectl wait --for=condition=Ready pods --all -n chaos-mesh --timeout=300s

echo "✅ Chaos Mesh deployed successfully!"
echo ""
echo "🎯 Access Chaos Dashboard:"
echo "kubectl port-forward -n chaos-mesh svc/chaos-dashboard 2333:2333"
echo "Then visit: http://localhost:2333"
echo ""
echo "📋 Available chaos experiments:"
echo "- Pod failures: k8s/chaos/pod-failure.yaml"
echo "- Network chaos: k8s/chaos/network-chaos.yaml"
echo "- Stress tests: k8s/chaos/stress-chaos.yaml"
echo "- HTTP chaos: k8s/chaos/http-chaos.yaml"
echo ""
echo "🧪 Run an experiment:"
echo "kubectl apply -f k8s/chaos/pod-failure.yaml"
