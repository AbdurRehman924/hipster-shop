#!/bin/bash
set -e

echo "🔒 Deploying Kyverno Policy Engine..."

# Add Kyverno Helm repo
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update

# Install Kyverno
echo "📦 Installing Kyverno..."
helm upgrade --install kyverno kyverno/kyverno \
    --namespace kyverno \
    --create-namespace \
    --set replicaCount=1 \
    --set resources.limits.memory=512Mi \
    --set resources.requests.memory=256Mi \
    --wait

echo "⏳ Waiting for Kyverno to be ready..."
kubectl wait --for=condition=Ready pods --all -n kyverno --timeout=300s

# Apply policies
echo "📋 Applying policies..."
kubectl apply -f k8s/policies/

echo "✅ Kyverno deployed successfully!"
echo ""
echo "📊 Check policy status:"
echo "kubectl get clusterpolicy"
echo ""
echo "🔍 View policy reports:"
echo "kubectl get policyreport -A"
echo ""
echo "📝 Test a policy violation:"
echo "kubectl run test-no-limits --image=nginx -n hipster-shop"
echo "(Should be blocked by require-resource-limits policy)"
