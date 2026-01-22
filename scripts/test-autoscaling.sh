#!/bin/bash
set -e

# Automated Scaling Test Script
# Tests HPA and VPA functionality with load simulation

echo "📈 Starting Automated Scaling Test..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
NAMESPACE="hipster-shop"
TEST_DURATION=${1:-300}  # 5 minutes default
LOAD_REPLICAS=${2:-5}    # Number of load generators

echo "Test Configuration:"
echo "  Duration: ${TEST_DURATION} seconds"
echo "  Load generators: ${LOAD_REPLICAS}"
echo "  Target namespace: ${NAMESPACE}"

# Check prerequisites
echo -e "\n${BLUE}🔍 Checking Prerequisites...${NC}"

# Check if HPA exists
if ! kubectl get hpa -n "$NAMESPACE" &>/dev/null; then
    echo -e "${YELLOW}⚠${NC} No HPA found. Deploying HPA for frontend..."
    cat << EOF | kubectl apply -f -
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: frontend-hpa
  namespace: $NAMESPACE
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: frontend
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
EOF
    echo "HPA created for frontend service"
fi

# Check if metrics server is available
if ! kubectl top nodes &>/dev/null; then
    echo -e "${RED}✗${NC} Metrics server not available. Please install metrics server first."
    exit 1
fi

# Record initial state
echo -e "\n${BLUE}📊 Recording Initial State...${NC}"
INITIAL_REPLICAS=$(kubectl get deployment frontend -n "$NAMESPACE" -o jsonpath='{.spec.replicas}')
echo "Initial frontend replicas: $INITIAL_REPLICAS"

kubectl get hpa -n "$NAMESPACE"
kubectl top pods -n "$NAMESPACE"

# Create load generator
echo -e "\n${BLUE}🚀 Starting Load Generation...${NC}"

cat << 'EOF' > /tmp/load-generator.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: load-generator-test
  namespace: hipster-shop
spec:
  replicas: 5
  selector:
    matchLabels:
      app: load-generator-test
  template:
    metadata:
      labels:
        app: load-generator-test
    spec:
      containers:
      - name: load-generator
        image: busybox
        command:
        - /bin/sh
        - -c
        - |
          while true; do
            wget -q -O- http://frontend:8080/ >/dev/null 2>&1
            wget -q -O- http://frontend:8080/product/OLJCESPC7Z >/dev/null 2>&1
            sleep 0.1
          done
        resources:
          requests:
            cpu: 100m
            memory: 64Mi
          limits:
            cpu: 200m
            memory: 128Mi
EOF

kubectl apply -f /tmp/load-generator.yaml

# Wait for load generators to start
echo "Waiting for load generators to start..."
kubectl wait --for=condition=ready pod -l app=load-generator-test -n "$NAMESPACE" --timeout=60s

# Monitor scaling for specified duration
echo -e "\n${BLUE}📈 Monitoring Scaling Behavior...${NC}"
echo "Monitoring for $TEST_DURATION seconds..."

START_TIME=$(date +%s)
END_TIME=$((START_TIME + TEST_DURATION))

# Create monitoring log
LOG_FILE="/tmp/scaling-test-$(date +%Y%m%d-%H%M%S).log"
echo "Scaling test log: $LOG_FILE"

echo "Timestamp,Replicas,CPU_Usage,Memory_Usage,HPA_Status" > "$LOG_FILE"

while [ $(date +%s) -lt $END_TIME ]; do
    CURRENT_TIME=$(date +%Y-%m-%d\ %H:%M:%S)
    CURRENT_REPLICAS=$(kubectl get deployment frontend -n "$NAMESPACE" -o jsonpath='{.spec.replicas}')
    
    # Get resource usage
    CPU_USAGE=$(kubectl top pod -n "$NAMESPACE" -l app=frontend --no-headers | awk '{sum+=$2} END {print sum}' | sed 's/m//')
    MEMORY_USAGE=$(kubectl top pod -n "$NAMESPACE" -l app=frontend --no-headers | awk '{sum+=$3} END {print sum}' | sed 's/Mi//')
    
    # Get HPA status
    HPA_STATUS=$(kubectl get hpa frontend-hpa -n "$NAMESPACE" -o jsonpath='{.status.currentReplicas}/{.status.desiredReplicas}')
    
    echo "$CURRENT_TIME,$CURRENT_REPLICAS,$CPU_USAGE,$MEMORY_USAGE,$HPA_STATUS" >> "$LOG_FILE"
    
    echo -e "${YELLOW}$(date +%H:%M:%S)${NC} Replicas: $CURRENT_REPLICAS, CPU: ${CPU_USAGE}m, Memory: ${MEMORY_USAGE}Mi, HPA: $HPA_STATUS"
    
    sleep 10
done

# Stop load generation
echo -e "\n${BLUE}🛑 Stopping Load Generation...${NC}"
kubectl delete deployment load-generator-test -n "$NAMESPACE"

# Monitor scale down
echo -e "\n${BLUE}📉 Monitoring Scale Down...${NC}"
echo "Waiting for scale down (up to 5 minutes)..."

SCALE_DOWN_START=$(date +%s)
SCALE_DOWN_END=$((SCALE_DOWN_START + 300))

while [ $(date +%s) -lt $SCALE_DOWN_END ]; do
    CURRENT_REPLICAS=$(kubectl get deployment frontend -n "$NAMESPACE" -o jsonpath='{.spec.replicas}')
    echo -e "${YELLOW}$(date +%H:%M:%S)${NC} Current replicas: $CURRENT_REPLICAS"
    
    if [ "$CURRENT_REPLICAS" -le "$INITIAL_REPLICAS" ]; then
        echo -e "${GREEN}✓${NC} Scaled down to initial state"
        break
    fi
    
    sleep 30
done

# Generate test report
echo -e "\n${GREEN}📋 Scaling Test Report${NC}"
echo "======================"

FINAL_REPLICAS=$(kubectl get deployment frontend -n "$NAMESPACE" -o jsonpath='{.spec.replicas}')
MAX_REPLICAS=$(tail -n +2 "$LOG_FILE" | cut -d',' -f2 | sort -n | tail -1)

echo "Initial replicas: $INITIAL_REPLICAS"
echo "Maximum replicas reached: $MAX_REPLICAS"
echo "Final replicas: $FINAL_REPLICAS"
echo "Test duration: $TEST_DURATION seconds"

# Calculate scaling metrics
if [ "$MAX_REPLICAS" -gt "$INITIAL_REPLICAS" ]; then
    echo -e "${GREEN}✓${NC} HPA successfully scaled up from $INITIAL_REPLICAS to $MAX_REPLICAS replicas"
else
    echo -e "${RED}✗${NC} HPA did not scale up during the test"
fi

if [ "$FINAL_REPLICAS" -le "$INITIAL_REPLICAS" ]; then
    echo -e "${GREEN}✓${NC} HPA successfully scaled down to $FINAL_REPLICAS replicas"
else
    echo -e "${YELLOW}⚠${NC} HPA has not yet scaled down completely"
fi

# Show HPA events
echo -e "\n${BLUE}📝 HPA Events:${NC}"
kubectl describe hpa frontend-hpa -n "$NAMESPACE" | grep -A 10 "Events:"

# VPA recommendations if available
if kubectl get vpa -n "$NAMESPACE" &>/dev/null; then
    echo -e "\n${BLUE}💡 VPA Recommendations:${NC}"
    kubectl describe vpa -n "$NAMESPACE" | grep -A 20 "Recommendation:"
fi

echo -e "\n${GREEN}✅ Scaling test completed!${NC}"
echo "Detailed log available at: $LOG_FILE"

# Cleanup
rm -f /tmp/load-generator.yaml

echo -e "\n${BLUE}📊 Final Resource Usage:${NC}"
kubectl top pods -n "$NAMESPACE"
