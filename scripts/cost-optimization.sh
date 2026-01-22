#!/bin/bash
set -e

# Cost Optimization Script for Hipster Shop Platform
# Analyzes resource usage and provides optimization recommendations

echo "💰 Starting Cost Optimization Analysis..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if metrics server is available
if ! kubectl top nodes &>/dev/null; then
    echo -e "${YELLOW}⚠${NC} Metrics server not available. Installing..."
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
    echo "Waiting for metrics server to be ready..."
    kubectl wait --for=condition=ready pod -l k8s-app=metrics-server -n kube-system --timeout=60s
    sleep 10
fi

echo -e "\n📊 Current Resource Usage Analysis"
echo "=================================="

# Node resource analysis
echo -e "\n${BLUE}🖥️  Node Resource Utilization:${NC}"
kubectl top nodes

# Pod resource analysis
echo -e "\n${BLUE}📦 Pod Resource Usage (Top 10):${NC}"
kubectl top pods -A --sort-by=cpu | head -11

# Identify over-provisioned pods
echo -e "\n${YELLOW}🔍 Over-Provisioned Pods Analysis:${NC}"
kubectl get pods -A -o json | jq -r '
.items[] | 
select(.spec.containers[0].resources.requests.cpu != null) |
"\(.metadata.namespace)/\(.metadata.name) - CPU Request: \(.spec.containers[0].resources.requests.cpu // "none") Memory Request: \(.spec.containers[0].resources.requests.memory // "none")"
' | while read line; do
    echo "  $line"
done

# Check for pods without resource limits
echo -e "\n${RED}⚠️  Pods Without Resource Limits:${NC}"
kubectl get pods -A -o json | jq -r '
.items[] | 
select(.spec.containers[0].resources.limits == null) |
"  \(.metadata.namespace)/\(.metadata.name)"
'

# Storage usage analysis
echo -e "\n${BLUE}💾 Storage Usage:${NC}"
kubectl get pv -o custom-columns=NAME:.metadata.name,CAPACITY:.spec.capacity.storage,STATUS:.status.phase,CLAIM:.spec.claimRef.name

# Service analysis for LoadBalancer costs
echo -e "\n${BLUE}🌐 LoadBalancer Services (Cost Impact):${NC}"
LB_COUNT=$(kubectl get svc -A --field-selector spec.type=LoadBalancer --no-headers | wc -l)
echo "  LoadBalancer services found: $LB_COUNT"
echo "  Estimated monthly cost: \$$(($LB_COUNT * 12))"
kubectl get svc -A --field-selector spec.type=LoadBalancer -o custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,TYPE:.spec.type,EXTERNAL-IP:.status.loadBalancer.ingress[0].ip

# Generate optimization recommendations
echo -e "\n${GREEN}💡 Cost Optimization Recommendations:${NC}"
echo "======================================"

# Check for unused PVCs
UNUSED_PVCS=$(kubectl get pvc -A --no-headers | grep -v Bound | wc -l)
if [ "$UNUSED_PVCS" -gt 0 ]; then
    echo -e "${YELLOW}1.${NC} Found $UNUSED_PVCS unused PVCs - consider cleaning up"
fi

# Check for multiple LoadBalancers
if [ "$LB_COUNT" -gt 1 ]; then
    echo -e "${YELLOW}2.${NC} Multiple LoadBalancers detected - consider using Ingress Controller"
    echo "   Potential savings: \$$(( ($LB_COUNT - 1) * 12 ))/month"
fi

# Check for pods without resource requests
NO_REQUESTS=$(kubectl get pods -A -o json | jq '[.items[] | select(.spec.containers[0].resources.requests == null)] | length')
if [ "$NO_REQUESTS" -gt 0 ]; then
    echo -e "${YELLOW}3.${NC} $NO_REQUESTS pods without resource requests - add requests for better scheduling"
fi

# Check for pods without resource limits
NO_LIMITS=$(kubectl get pods -A -o json | jq '[.items[] | select(.spec.containers[0].resources.limits == null)] | length')
if [ "$NO_LIMITS" -gt 0 ]; then
    echo -e "${YELLOW}4.${NC} $NO_LIMITS pods without resource limits - add limits to prevent resource hogging"
fi

# HPA recommendations
HPA_COUNT=$(kubectl get hpa -A --no-headers | wc -l)
DEPLOYMENT_COUNT=$(kubectl get deployments -A --no-headers | wc -l)
if [ "$HPA_COUNT" -lt "$DEPLOYMENT_COUNT" ]; then
    echo -e "${YELLOW}5.${NC} Consider adding HPA to more deployments for automatic scaling"
fi

# VPA recommendations
if ! kubectl get vpa -A &>/dev/null; then
    echo -e "${YELLOW}6.${NC} Consider deploying VPA for automatic resource right-sizing"
fi

# Generate resource optimization YAML
echo -e "\n${BLUE}📝 Generating Resource Optimization Manifests...${NC}"

cat > /tmp/resource-optimization.yaml << 'EOF'
# Resource optimization recommendations
apiVersion: v1
kind: ConfigMap
metadata:
  name: cost-optimization-recommendations
  namespace: kube-system
data:
  recommendations.md: |
    # Cost Optimization Recommendations
    
    ## Resource Right-Sizing
    - Add resource requests and limits to all pods
    - Use VPA for automatic resource recommendations
    - Monitor actual usage vs requested resources
    
    ## Network Cost Optimization
    - Use single Ingress Controller instead of multiple LoadBalancers
    - Implement network policies to reduce unnecessary traffic
    - Consider using NodePort for internal services
    
    ## Storage Optimization
    - Clean up unused PVCs and PVs
    - Use appropriate storage classes for different workloads
    - Implement storage lifecycle policies
    
    ## Scaling Optimization
    - Implement HPA for automatic scaling
    - Use cluster autoscaler for node scaling
    - Set appropriate min/max replicas
    
    ## Monitoring and Alerting
    - Set up cost monitoring with Kubecost
    - Create alerts for resource usage thresholds
    - Regular cost reviews and optimization cycles
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: cost-optimization-pdb
  namespace: hipster-shop
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: frontend
---
# Example resource-optimized deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: resource-optimized-example
  namespace: hipster-shop
spec:
  replicas: 2
  selector:
    matchLabels:
      app: optimized-app
  template:
    metadata:
      labels:
        app: optimized-app
    spec:
      containers:
      - name: app
        image: nginx:alpine
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 256Mi
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
EOF

echo "  Resource optimization manifest created: /tmp/resource-optimization.yaml"

# Calculate potential savings
echo -e "\n${GREEN}💵 Potential Monthly Savings:${NC}"
echo "=========================="
CURRENT_LB_COST=$(($LB_COUNT * 12))
OPTIMIZED_LB_COST=12  # Assuming single ingress controller
LB_SAVINGS=$(($CURRENT_LB_COST - $OPTIMIZED_LB_COST))

echo "  Current LoadBalancer cost: \$$CURRENT_LB_COST/month"
echo "  Optimized LoadBalancer cost: \$$OPTIMIZED_LB_COST/month"
echo "  Potential LoadBalancer savings: \$$LB_SAVINGS/month"

# Node optimization suggestions
NODE_COUNT=$(kubectl get nodes --no-headers | wc -l)
echo "  Current nodes: $NODE_COUNT"
echo "  Consider cluster autoscaler for dynamic node scaling"

echo -e "\n${GREEN}✅ Cost optimization analysis completed!${NC}"
echo -e "\n${BLUE}📋 Next Steps:${NC}"
echo "1. Review resource requests/limits for all applications"
echo "2. Implement Ingress Controller to reduce LoadBalancer costs"
echo "3. Deploy VPA for automatic resource recommendations"
echo "4. Set up Kubecost for ongoing cost monitoring"
echo "5. Implement cluster autoscaler for node optimization"
