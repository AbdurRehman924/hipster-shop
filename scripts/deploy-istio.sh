#!/bin/bash

echo "🕸️  Installing Istio Service Mesh..."

# Check if istioctl is installed
if ! command -v istioctl &> /dev/null; then
    echo "Installing istioctl..."
    curl -L https://istio.io/downloadIstio | sh -
    export PATH="$PWD/istio-*/bin:$PATH"
fi

# Install Istio
echo "Installing Istio control plane..."
istioctl install --set values.defaultRevision=default -y

# Enable sidecar injection
echo "Enabling sidecar injection for hipster-shop namespace..."
kubectl label namespace hipster-shop istio-injection=enabled --overwrite

# Apply Istio configurations
echo "Applying Istio configurations..."
kubectl apply -f k8s/istio/

# Restart deployments to inject sidecars
echo "Restarting deployments to inject Envoy sidecars..."
kubectl rollout restart deployment -n hipster-shop

# Wait for rollout
echo "Waiting for deployments to be ready..."
kubectl rollout status deployment --all -n hipster-shop --timeout=300s

# Get Istio ingress gateway IP
echo "Getting Istio ingress gateway external IP..."
INGRESS_IP=$(kubectl get svc istio-ingressgateway -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo ""
echo "✅ Istio service mesh deployed successfully!"
echo ""
echo "🌐 Access URLs:"
echo "Application: http://$INGRESS_IP"
echo "Kiali (Service Mesh Dashboard): http://$INGRESS_IP:20001"
echo "Jaeger (Tracing): http://$INGRESS_IP:16686"
echo "Grafana (Istio Metrics): http://$INGRESS_IP:3000"
echo ""
echo "📚 Learning Resources:"
echo "- Istio Traffic Management: https://istio.io/latest/docs/concepts/traffic-management/"
echo "- Security Policies: https://istio.io/latest/docs/concepts/security/"
echo "- Observability: https://istio.io/latest/docs/concepts/observability/"
