#!/bin/bash
set -e

echo "🚀 Deploying Autoscaling (HPA/VPA)..."

# Check if metrics-server is running
if ! kubectl get deployment metrics-server -n kube-system &>/dev/null; then
    echo "📊 Installing metrics-server..."
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
    
    # Patch for DigitalOcean
    kubectl patch deployment metrics-server -n kube-system --type='json' \
        -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'
    
    echo "⏳ Waiting for metrics-server..."
    kubectl wait --for=condition=available --timeout=300s deployment/metrics-server -n kube-system
fi

# Install VPA if not present
if ! kubectl get crd verticalpodautoscalers.autoscaling.k8s.io &>/dev/null; then
    echo "📈 Installing VPA..."
    git clone https://github.com/kubernetes/autoscaler.git /tmp/autoscaler || true
    cd /tmp/autoscaler/vertical-pod-autoscaler/
    ./hack/vpa-install.sh
    cd - > /dev/null
fi

# Apply HPA configurations
echo "🔄 Applying HPA configurations..."
kubectl apply -f k8s/autoscaling/hpa.yaml

# Apply VPA configurations
echo "📊 Applying VPA configurations..."
kubectl apply -f k8s/autoscaling/vpa.yaml

echo "✅ Autoscaling deployed successfully!"
echo ""
echo "📋 Check status:"
echo "kubectl get hpa -n hipster-shop"
echo "kubectl get vpa -n hipster-shop"
echo "kubectl top pods -n hipster-shop"
