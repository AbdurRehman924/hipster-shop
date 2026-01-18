#!/bin/bash
set -e

echo "🧪 Testing Security Scanning & Compliance..."

# Test Trivy vulnerability scanning
echo "1️⃣  Testing Trivy Vulnerability Scanning..."
if kubectl get namespace trivy-system &>/dev/null; then
    echo "✅ Trivy namespace exists"
    
    # Trigger a scan
    kubectl annotate deployment frontend trivy.scan/trigger=$(date +%s) -n hipster-shop --overwrite
    
    echo "⏳ Waiting for vulnerability reports..."
    sleep 30
    
    VULN_REPORTS=$(kubectl get vulnerabilityreports -n hipster-shop --no-headers 2>/dev/null | wc -l)
    if [ "$VULN_REPORTS" -gt 0 ]; then
        echo "✅ Found $VULN_REPORTS vulnerability reports"
        kubectl get vulnerabilityreports -n hipster-shop
    else
        echo "⚠️  No vulnerability reports found yet (may take a few minutes)"
    fi
else
    echo "❌ Trivy not deployed. Run: ./scripts/deploy-security.sh"
fi

echo ""
echo "---"
echo ""

# Test Gatekeeper policies
echo "2️⃣  Testing Gatekeeper Policies..."
if kubectl get namespace gatekeeper-system &>/dev/null; then
    echo "✅ Gatekeeper namespace exists"
    
    echo "📋 Active constraints:"
    kubectl get constraints
    
    echo ""
    echo "🧪 Testing policy violations:"
    
    # Test 1: Try to create pod without required labels
    echo "Test 1: Pod without required labels (should be blocked)"
    kubectl run test-no-labels --image=nginx -n hipster-shop --dry-run=server 2>&1 | grep -q "denied" && echo "✅ Blocked correctly" || echo "❌ Should have been blocked"
    
    # Test 2: Try to create LoadBalancer service
    echo "Test 2: LoadBalancer service (should be blocked)"
    cat <<EOF | kubectl apply --dry-run=server -f - 2>&1 | grep -q "denied" && echo "✅ Blocked correctly" || echo "❌ Should have been blocked"
apiVersion: v1
kind: Service
metadata:
  name: test-lb
  namespace: hipster-shop
spec:
  type: LoadBalancer
  ports:
  - port: 80
  selector:
    app: test
EOF

else
    echo "❌ Gatekeeper not deployed. Run: ./scripts/deploy-security.sh"
fi

echo ""
echo "---"
echo ""

# Test Falco runtime security
echo "3️⃣  Testing Falco Runtime Security..."
if kubectl get namespace falco &>/dev/null; then
    echo "✅ Falco namespace exists"
    kubectl get pods -n falco
    
    echo ""
    echo "🦅 Recent Falco events (last 10):"
    kubectl logs -n falco -l app.kubernetes.io/name=falco --tail=10 | grep -E "(WARNING|CRITICAL)" || echo "No recent security events"
    
    echo ""
    echo "🧪 Generate test security event:"
    echo "kubectl exec -it deployment/frontend -n hipster-shop -- /bin/sh"
    echo "(This will trigger a 'Shell spawned in container' alert)"
    
else
    echo "❌ Falco not deployed. Run: ./scripts/deploy-security.sh"
fi

echo ""
echo "---"
echo ""
echo "✅ Security testing complete!"
echo ""
echo "📊 View security dashboard:"
echo "kubectl port-forward svc/grafana 3000:80 -n monitoring"
echo "Then go to Dashboards > Security Dashboard"
