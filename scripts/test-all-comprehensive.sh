#!/bin/bash

# Comprehensive Test Script for Hipster Shop Platform
# Tests all components and validates complete platform health

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test results tracking
TESTS_PASSED=0
TESTS_FAILED=0
FAILED_TESTS=()

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((TESTS_PASSED++))
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((TESTS_FAILED++))
    FAILED_TESTS+=("$1")
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

run_test() {
    local test_name="$1"
    local test_command="$2"
    
    log_info "Running: $test_name"
    echo -e "${BLUE}Command:${NC} $test_command"
    
    # Capture both stdout and stderr
    local output
    local exit_code
    
    output=$(eval "$test_command" 2>&1)
    exit_code=$?
    
    # Show command output
    if [ -n "$output" ]; then
        echo -e "${YELLOW}Output:${NC}"
        echo "$output" | sed 's/^/  /'
    fi
    
    if [ $exit_code -eq 0 ]; then
        log_success "$test_name"
    else
        log_error "$test_name"
    fi
    echo ""
}

echo "=========================================="
echo "  HIPSTER SHOP COMPREHENSIVE TEST SUITE"
echo "=========================================="
echo "Started at: $(date)"
echo ""

# 1. Infrastructure Tests
log_info "=== INFRASTRUCTURE TESTS ==="

run_test "Kubernetes cluster connectivity" "kubectl cluster-info"
run_test "All nodes ready" "kubectl get nodes | grep -v NotReady"
run_test "Terraform state valid" "cd terraform-infra && terraform plan -detailed-exitcode"

# 2. Application Deployment Tests
log_info "=== APPLICATION DEPLOYMENT TESTS ==="

run_test "Hipster-shop namespace exists" "kubectl get namespace hipster-shop"
run_test "All pods running" "kubectl get pods -n hipster-shop --field-selector=status.phase=Running | grep -q Running"
run_test "No failed pods" "! kubectl get pods -n hipster-shop --field-selector=status.phase=Failed | grep -q Failed"
run_test "All services have endpoints" "kubectl get endpoints -n hipster-shop | grep -v '<none>'"
run_test "Frontend service accessible" "kubectl get svc frontend -n hipster-shop"

# 3. Service Connectivity Tests
log_info "=== SERVICE CONNECTIVITY TESTS ==="

run_test "Frontend to ProductCatalog connectivity" "kubectl exec deployment/frontend -n hipster-shop -- wget -qO- --timeout=10 http://productcatalogservice:3550/products"
run_test "Frontend to Currency connectivity" "kubectl exec deployment/frontend -n hipster-shop -- wget -qO- --timeout=10 http://currencyservice:7000"
run_test "Cart service health" "kubectl exec deployment/cartservice -n hipster-shop -- nc -z localhost 7070"

# 4. Monitoring Stack Tests
log_info "=== MONITORING STACK TESTS ==="

run_test "Monitoring namespace exists" "kubectl get namespace monitoring"
run_test "Prometheus running" "kubectl get pods -n monitoring -l app=prometheus | grep Running"
run_test "Grafana running" "kubectl get pods -n monitoring -l app=grafana | grep Running"
run_test "Prometheus targets healthy" "kubectl exec -n monitoring deployment/prometheus -- wget -qO- http://localhost:9090/api/v1/targets | grep -q '\"health\":\"up\"'"

# 5. Security Tests
log_info "=== SECURITY TESTS ==="

if kubectl get namespace trivy-system &>/dev/null; then
    run_test "Trivy operator running" "kubectl get pods -n trivy-system | grep Running"
    run_test "Vulnerability reports exist" "kubectl get vulnerabilityreports -A | grep -q vulnerabilityreports"
fi

if kubectl get namespace falco &>/dev/null; then
    run_test "Falco running" "kubectl get pods -n falco | grep Running"
fi

run_test "Network policies exist" "kubectl get networkpolicies -n hipster-shop | grep -q networkpolicies"
run_test "Pod security standards" "kubectl get pods -n hipster-shop -o jsonpath='{.items[*].spec.securityContext}' | grep -q runAsNonRoot"

# 6. Autoscaling Tests
log_info "=== AUTOSCALING TESTS ==="

run_test "HPA configured" "kubectl get hpa -n hipster-shop | grep -q hpa"
run_test "VPA configured" "kubectl get vpa -n hipster-shop | grep -q vpa"
run_test "Metrics server running" "kubectl get pods -n kube-system -l k8s-app=metrics-server | grep Running"

# 7. Backup Tests
log_info "=== BACKUP TESTS ==="

if kubectl get namespace velero &>/dev/null; then
    run_test "Velero running" "kubectl get pods -n velero | grep Running"
    run_test "Backup schedules exist" "kubectl get schedules -n velero | grep -q schedules"
fi

# 8. GitOps Tests
log_info "=== GITOPS TESTS ==="

if kubectl get namespace argocd &>/dev/null; then
    run_test "ArgoCD running" "kubectl get pods -n argocd | grep Running"
    run_test "Applications synced" "kubectl get applications -n argocd -o jsonpath='{.items[*].status.sync.status}' | grep -q Synced"
fi

# 9. Service Mesh Tests (if Istio is deployed)
log_info "=== SERVICE MESH TESTS ==="

if kubectl get namespace istio-system &>/dev/null; then
    run_test "Istio control plane running" "kubectl get pods -n istio-system | grep Running"
    run_test "Sidecar injection enabled" "kubectl get namespace hipster-shop -o jsonpath='{.metadata.labels.istio-injection}' | grep -q enabled"
    run_test "Virtual services exist" "kubectl get virtualservices -n hipster-shop | grep -q virtualservices"
fi

# 10. Performance Tests
log_info "=== PERFORMANCE TESTS ==="

run_test "Resource limits set" "kubectl get pods -n hipster-shop -o jsonpath='{.items[*].spec.containers[*].resources.limits}' | grep -q cpu"
run_test "CPU usage under 80%" "kubectl top pods -n hipster-shop --no-headers | awk '{if(\$3 > 80) exit 1}'"
run_test "Memory usage under 80%" "kubectl top pods -n hipster-shop --no-headers | awk '{if(\$4 > 80) exit 1}'"

# 11. Application Health Tests
log_info "=== APPLICATION HEALTH TESTS ==="

# Test frontend accessibility
FRONTEND_PORT=$(kubectl get svc frontend -n hipster-shop -o jsonpath='{.spec.ports[0].port}')
run_test "Frontend HTTP response" "kubectl exec deployment/frontend -n hipster-shop -- wget -qO- --timeout=10 http://localhost:$FRONTEND_PORT | grep -q 'Online Boutique'"

# Test key microservices
run_test "Product catalog responsive" "kubectl exec deployment/productcatalogservice -n hipster-shop -- nc -z localhost 3550"
run_test "Cart service responsive" "kubectl exec deployment/cartservice -n hipster-shop -- nc -z localhost 7070"
run_test "Checkout service responsive" "kubectl exec deployment/checkoutservice -n hipster-shop -- nc -z localhost 5050"

# 12. Configuration Validation
log_info "=== CONFIGURATION VALIDATION ==="

run_test "ConfigMaps exist" "kubectl get configmaps -n hipster-shop | grep -q configmaps"
run_test "Secrets exist" "kubectl get secrets -n hipster-shop | grep -q secrets"
run_test "YAML manifests valid" "find k8s/ -name '*.yaml' -exec kubectl --dry-run=client apply -f {} \;"

# Final Results
echo ""
echo "=========================================="
echo "           TEST RESULTS SUMMARY"
echo "=========================================="
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
echo -e "Total Tests:  $((TESTS_PASSED + TESTS_FAILED))"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}🎉 ALL TESTS PASSED! Platform is healthy.${NC}"
    exit 0
else
    echo -e "\n${RED}❌ SOME TESTS FAILED:${NC}"
    for test in "${FAILED_TESTS[@]}"; do
        echo -e "  ${RED}•${NC} $test"
    done
    echo ""
    echo -e "${YELLOW}💡 Run individual test scripts for detailed diagnostics:${NC}"
    echo "  ./scripts/health-check.sh"
    echo "  ./scripts/test-security.sh"
    echo "  ./scripts/test-network-policies.sh"
    echo "  ./scripts/test-autoscaling.sh"
    exit 1
fi
