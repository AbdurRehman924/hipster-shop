# Chaos Engineering Guide

Learn to test system resilience with Chaos Mesh.

## 🎯 What You'll Learn

- **Pod Chaos**: Simulate pod failures and kills
- **Network Chaos**: Inject latency, packet loss, partitions
- **Stress Testing**: CPU and memory pressure
- **HTTP Chaos**: Simulate API failures and delays

## 🚀 Quick Start

```bash
# Deploy Chaos Mesh
./scripts/deploy-chaos.sh

# Access dashboard
kubectl port-forward -n chaos-mesh svc/chaos-dashboard 2333:2333
# Visit: http://localhost:2333
```

## 🧪 Experiments

### 1. Pod Failure
```bash
# Kill cart service pods randomly
kubectl apply -f k8s/chaos/pod-failure.yaml

# Watch the impact
kubectl get pods -n hipster-shop -w
```

### 2. Network Latency
```bash
# Add 500ms delay to product catalog
kubectl apply -f k8s/chaos/network-chaos.yaml

# Monitor response times in Grafana
```

### 3. Resource Stress
```bash
# Stress CPU on frontend
kubectl apply -f k8s/chaos/stress-chaos.yaml

# Watch HPA scale up
kubectl get hpa -n hipster-shop -w
```

### 4. HTTP Failures
```bash
# Abort cart requests
kubectl apply -f k8s/chaos/http-chaos.yaml

# Check error rates in Prometheus
```

## 📊 Monitor Impact

```bash
# Check pod status
kubectl get pods -n hipster-shop

# View logs
kubectl logs -f deployment/frontend -n hipster-shop

# Prometheus queries
rate(http_requests_total{status=~"5.."}[5m])
```

## 🛑 Stop Experiments

```bash
# Delete specific experiment
kubectl delete -f k8s/chaos/pod-failure.yaml

# Delete all experiments
kubectl delete podchaos,networkchaos,stresschaos,httpchaos --all -n hipster-shop
```

## 🎓 Learning Exercises

1. **Test HPA**: Run CPU stress and watch autoscaling
2. **Test Circuit Breaking**: Inject failures and observe Istio behavior
3. **Test Monitoring**: Verify alerts trigger during chaos
4. **Test Recovery**: Measure time to recover from failures
