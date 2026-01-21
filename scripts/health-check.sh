#!/bin/bash
set -e

# Health Check Script for Hipster Shop Platform
# Validates all components are running correctly

echo "🔍 Starting Hipster Shop Health Check..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check functions
check_namespace() {
    local ns=$1
    if kubectl get namespace "$ns" &>/dev/null; then
        echo -e "${GREEN}✓${NC} Namespace $ns exists"
        return 0
    else
        echo -e "${RED}✗${NC} Namespace $ns not found"
        return 1
    fi
}

check_pods() {
    local ns=$1
    local ready_pods=$(kubectl get pods -n "$ns" --no-headers | grep "Running" | grep -E "([0-9]+)/\1" | wc -l)
    local total_pods=$(kubectl get pods -n "$ns" --no-headers | wc -l)
    
    if [ "$ready_pods" -eq "$total_pods" ] && [ "$total_pods" -gt 0 ]; then
        echo -e "${GREEN}✓${NC} All pods in $ns are ready ($ready_pods/$total_pods)"
        return 0
    else
        echo -e "${RED}✗${NC} Pods in $ns not ready ($ready_pods/$total_pods)"
        kubectl get pods -n "$ns" | grep -v "Running\|Completed"
        return 1
    fi
}

check_service_endpoint() {
    local service=$1
    local ns=$2
    local port=$3
    
    if kubectl get svc "$service" -n "$ns" &>/dev/null; then
        local cluster_ip=$(kubectl get svc "$service" -n "$ns" -o jsonpath='{.spec.clusterIP}')
        if [ "$cluster_ip" != "None" ] && [ "$cluster_ip" != "" ]; then
            echo -e "${GREEN}✓${NC} Service $service in $ns is accessible"
            return 0
        fi
    fi
    echo -e "${RED}✗${NC} Service $service in $ns is not accessible"
    return 1
}

# Main health checks
echo "📋 Checking Core Application..."
check_namespace "hipster-shop"
check_pods "hipster-shop"

echo -e "\n📊 Checking Monitoring Stack..."
check_namespace "monitoring"
check_pods "monitoring"
check_service_endpoint "prometheus" "monitoring" "9090"
check_service_endpoint "grafana" "monitoring" "80"

echo -e "\n🔒 Checking Security Components..."
if kubectl get namespace "falco" &>/dev/null; then
    check_pods "falco"
fi

if kubectl get namespace "trivy-system" &>/dev/null; then
    check_pods "trivy-system"
fi

echo -e "\n🌐 Checking Networking..."
if kubectl get namespace "ingress-nginx" &>/dev/null; then
    check_pods "ingress-nginx"
    check_service_endpoint "ingress-nginx-controller" "ingress-nginx" "80"
fi

echo -e "\n🕸️ Checking Service Mesh..."
if kubectl get namespace "istio-system" &>/dev/null; then
    check_pods "istio-system"
    check_service_endpoint "istiod" "istio-system" "15010"
fi

echo -e "\n💾 Checking Backup System..."
if kubectl get namespace "velero" &>/dev/null; then
    check_pods "velero"
fi

# Application connectivity test
echo -e "\n🔗 Testing Application Connectivity..."
if kubectl get svc frontend -n hipster-shop &>/dev/null; then
    kubectl run health-test --image=curlimages/curl --rm -i --restart=Never -- \
        curl -s -o /dev/null -w "%{http_code}" http://frontend.hipster-shop:8080 | \
        grep -q "200" && echo -e "${GREEN}✓${NC} Frontend service responding" || \
        echo -e "${RED}✗${NC} Frontend service not responding"
fi

# Resource usage check
echo -e "\n📈 Resource Usage Summary..."
kubectl top nodes 2>/dev/null || echo -e "${YELLOW}⚠${NC} Metrics server not available"
kubectl top pods -n hipster-shop 2>/dev/null || echo -e "${YELLOW}⚠${NC} Pod metrics not available"

echo -e "\n✅ Health check completed!"
