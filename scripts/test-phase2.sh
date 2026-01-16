#!/bin/bash
set -e

echo "🧪 Testing Chaos Engineering, Policies, and Cost Analysis..."
echo ""

# Test Chaos Mesh
echo "1️⃣  Testing Chaos Mesh..."
if kubectl get namespace chaos-mesh &>/dev/null; then
    echo "✅ Chaos Mesh namespace exists"
    kubectl get pods -n chaos-mesh
    echo ""
    echo "🧪 Run a test experiment:"
    echo "kubectl apply -f k8s/chaos/pod-failure.yaml"
else
    echo "❌ Chaos Mesh not deployed. Run: ./scripts/deploy-chaos.sh"
fi

echo ""
echo "---"
echo ""

# Test Kyverno
echo "2️⃣  Testing Kyverno Policies..."
if kubectl get namespace kyverno &>/dev/null; then
    echo "✅ Kyverno namespace exists"
    echo ""
    echo "📋 Active policies:"
    kubectl get clusterpolicy
    echo ""
    echo "🧪 Test policy enforcement:"
    echo "kubectl run test-no-limits --image=nginx -n hipster-shop"
    echo "(Should be blocked by require-resource-limits policy)"
else
    echo "❌ Kyverno not deployed. Run: ./scripts/deploy-policies.sh"
fi

echo ""
echo "---"
echo ""

# Test Kubecost
echo "3️⃣  Testing Kubecost..."
if kubectl get namespace kubecost &>/dev/null; then
    echo "✅ Kubecost namespace exists"
    kubectl get pods -n kubecost
    echo ""
    echo "💰 Access cost dashboard:"
    echo "kubectl port-forward -n kubecost svc/kubecost-cost-analyzer 9090:9090"
else
    echo "❌ Kubecost not deployed. Run: ./scripts/deploy-kubecost.sh"
fi

echo ""
echo "---"
echo ""
echo "✅ Testing complete!"
