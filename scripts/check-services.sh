#!/bin/bash

echo "Checking deployed services and their ports..."
echo "============================================="

# Check if namespaces exist
echo "Available namespaces:"
kubectl get namespaces | grep -E "(hipster-shop|monitoring|istio-system|argocd|kubecost)"
echo ""

# Check hipster-shop services
if kubectl get namespace hipster-shop &>/dev/null; then
    echo "Hipster Shop Services:"
    kubectl get svc -n hipster-shop -o custom-columns="NAME:.metadata.name,TYPE:.spec.type,PORT:.spec.ports[*].port,TARGET:.spec.ports[*].targetPort"
    echo ""
else
    echo "❌ hipster-shop namespace not found"
    echo ""
fi

# Check monitoring services
if kubectl get namespace monitoring &>/dev/null; then
    echo "Monitoring Services:"
    kubectl get svc -n monitoring -o custom-columns="NAME:.metadata.name,TYPE:.spec.type,PORT:.spec.ports[*].port,TARGET:.spec.ports[*].targetPort"
    echo ""
else
    echo "❌ monitoring namespace not found"
    echo ""
fi

# Check other important namespaces
for ns in istio-system argocd kubecost; do
    if kubectl get namespace $ns &>/dev/null; then
        echo "$ns Services:"
        kubectl get svc -n $ns -o custom-columns="NAME:.metadata.name,TYPE:.spec.type,PORT:.spec.ports[*].port,TARGET:.spec.ports[*].targetPort"
        echo ""
    fi
done

echo "Deployment Status:"
echo "=================="
echo "To deploy missing components:"
echo "make deploy              # Deploy everything"
echo "make deploy-app          # Deploy hipster-shop only"
echo "make deploy-monitoring   # Deploy monitoring only"
