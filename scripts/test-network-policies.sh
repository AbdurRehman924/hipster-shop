# Test network policies
echo "Testing network policies..."

# Create test pod
kubectl run test-pod --image=busybox -n hipster-shop --command -- sleep 3600

# Wait for pod
kubectl wait --for=condition=ready pod/test-pod -n hipster-shop --timeout=60s

echo ""
echo "❌ These should FAIL (blocked by network policies):"
echo "1. Test pod accessing cart service directly:"
kubectl exec test-pod -n hipster-shop -- timeout 5 wget -O- http://cartservice:7070 2>&1 || echo "✅ Correctly blocked"

echo ""
echo "2. Test pod accessing payment service:"
kubectl exec test-pod -n hipster-shop -- timeout 5 wget -O- http://paymentservice:50051 2>&1 || echo "✅ Correctly blocked"

echo ""
echo "✅ These should SUCCEED (allowed by network policies):"
echo "3. Frontend accessing cart service:"
FRONTEND_POD=$(kubectl get pod -n hipster-shop -l app=frontend -o jsonpath='{.items[0].metadata.name}')
kubectl exec $FRONTEND_POD -n hipster-shop -- timeout 5 wget -O- http://cartservice:7070 2>&1 | head -n 5

echo ""
echo "4. Checkout accessing payment service:"
CHECKOUT_POD=$(kubectl get pod -n hipster-shop -l app=checkoutservice -o jsonpath='{.items[0].metadata.name}')
kubectl exec $CHECKOUT_POD -n hipster-shop -- timeout 5 wget -O- http://paymentservice:50051 2>&1 | head -n 5

# Cleanup
kubectl delete pod test-pod -n hipster-shop

echo ""
echo "Network policy test complete!"
