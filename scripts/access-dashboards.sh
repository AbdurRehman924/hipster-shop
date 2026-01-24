#!/bin/bash

echo "Available Actions:"
echo "=================="
echo "1. Frontend (Main App)"
echo "2. Grafana (Monitoring)"
echo "3. Prometheus (Metrics)"
echo "4. Jaeger (Tracing)"
echo "5. Kiali (Service Mesh)"
echo "6. ArgoCD (GitOps)"
echo "7. Kubecost (Cost)"
echo "8. Stop All Port-Forwards"
echo "9. Show Active Port-Forwards"
echo ""

read -p "Select option (1-9): " choice

case $choice in
    1)
        echo "Starting Frontend..."
        kubectl port-forward svc/frontend 8080:80 -n hipster-shop
        ;;
    2)
        echo "Starting Grafana..."
        kubectl port-forward svc/grafana 3000:80 -n monitoring
        ;;
    3)
        echo "Starting Prometheus..."
        kubectl port-forward svc/prometheus 9090:9090 -n monitoring
        ;;
    4)
        echo "Starting Jaeger..."
        kubectl port-forward svc/jaeger 16686:16686 -n istio-system
        ;;
    5)
        echo "Starting Kiali..."
        kubectl port-forward svc/kiali 20001:20001 -n istio-system
        ;;
    6)
        echo "Starting ArgoCD..."
        kubectl port-forward svc/argocd-server 8080:443 -n argocd
        ;;
    7)
        echo "Starting Kubecost..."
        kubectl port-forward svc/kubecost-cost-analyzer 9090:9090 -n kubecost
        ;;
    8)
        echo "Stopping all port-forwards..."
        pkill -f "kubectl.*port-forward"
        echo "All port-forwards stopped."
        ;;
    9)
        echo "Active port-forwards:"
        ps aux | grep "kubectl.*port-forward" | grep -v grep
        ;;
    *)
        echo "Invalid choice"
        ;;
esac
