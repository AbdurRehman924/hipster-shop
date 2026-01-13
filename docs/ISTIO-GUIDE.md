# Istio Service Mesh Learning Guide

Learn advanced Kubernetes networking, security, and observability with Istio service mesh.

## 🎯 What You'll Learn

### **Service Mesh Fundamentals**
- **Sidecar Pattern**: Envoy proxy injection
- **Control Plane**: Istiod management
- **Data Plane**: Service-to-service communication

### **Traffic Management**
- **Intelligent Routing**: Canary deployments, A/B testing
- **Load Balancing**: Round-robin, least connection, random
- **Circuit Breaking**: Fault tolerance and resilience
- **Fault Injection**: Chaos engineering practices

### **Security**
- **mTLS**: Automatic mutual TLS between services
- **Authorization Policies**: Fine-grained access control
- **Security Policies**: Zero-trust networking

### **Observability**
- **Distributed Tracing**: Request flow across services
- **Service Topology**: Visual service dependencies
- **Advanced Metrics**: Golden signals with service mesh data

## 🚀 Quick Start

```bash
# Deploy Istio service mesh
./scripts/deploy-istio.sh

# Verify installation
kubectl get pods -n istio-system
kubectl get pods -n hipster-shop  # Should show 2/2 containers (app + sidecar)
```

## 🔍 Hands-On Exercises

### **Exercise 1: Traffic Splitting**
```yaml
# 90% to v1, 10% to v2 (canary deployment)
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: frontend-canary
spec:
  hosts:
  - frontend
  http:
  - match:
    - headers:
        canary:
          exact: "true"
    route:
    - destination:
        host: frontend
        subset: v2
  - route:
    - destination:
        host: frontend
        subset: v1
      weight: 90
    - destination:
        host: frontend
        subset: v2
      weight: 10
```

### **Exercise 2: Circuit Breaking**
```yaml
# Protect services from cascading failures
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: circuit-breaker
spec:
  host: productcatalogservice
  trafficPolicy:
    connectionPool:
      tcp:
        maxConnections: 10
      http:
        http1MaxPendingRequests: 5
        maxRequestsPerConnection: 2
    circuitBreaker:
      consecutiveErrors: 3
      interval: 30s
      baseEjectionTime: 30s
```

### **Exercise 3: Security Policies**
```yaml
# Only allow frontend to access cart service
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: cartservice-policy
spec:
  selector:
    matchLabels:
      app: cartservice
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/hipster-shop/sa/frontend"]
```

## 📊 Observability Tools

### **Kiali - Service Mesh Dashboard**
- **Service Graph**: Visual topology
- **Traffic Flow**: Real-time request patterns
- **Health Status**: Service and configuration health

### **Jaeger - Distributed Tracing**
- **Request Tracing**: End-to-end request flow
- **Performance Analysis**: Latency bottlenecks
- **Error Investigation**: Failed request debugging

### **Grafana - Istio Metrics**
- **Service Metrics**: Request rates, latencies, errors
- **Mesh Metrics**: Control plane health
- **Workload Metrics**: Pod-level performance

## 🧪 Chaos Engineering

### **Fault Injection**
```bash
# Inject 5-second delay in 10% of requests
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: fault-injection
spec:
  hosts:
  - productcatalogservice
  http:
  - fault:
      delay:
        percentage:
          value: 10
        fixedDelay: 5s
    route:
    - destination:
        host: productcatalogservice
EOF
```

### **Error Injection**
```bash
# Return HTTP 500 for 5% of requests
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: error-injection
spec:
  hosts:
  - cartservice
  http:
  - fault:
      abort:
        percentage:
          value: 5
        httpStatus: 500
    route:
    - destination:
        host: cartservice
EOF
```

## 🔧 Advanced Scenarios

### **Blue-Green Deployment**
1. Deploy new version (green)
2. Route small percentage of traffic
3. Monitor metrics and errors
4. Gradually shift traffic
5. Decommission old version (blue)

### **Multi-Cluster Mesh**
- Cross-cluster service discovery
- Multi-region deployments
- Disaster recovery patterns

### **Security Hardening**
- mTLS enforcement
- JWT validation
- Rate limiting
- DDoS protection

## 🎓 Production Best Practices

### **Performance**
- **Resource Limits**: Set CPU/memory for Envoy sidecars
- **Connection Pooling**: Optimize database connections
- **Caching**: Implement response caching

### **Security**
- **Least Privilege**: Minimal authorization policies
- **Certificate Rotation**: Automatic mTLS cert management
- **Audit Logging**: Track security events

### **Monitoring**
- **SLI/SLO Definition**: Service level objectives
- **Alert Rules**: Proactive issue detection
- **Capacity Planning**: Resource utilization trends

## 📚 Certification Prep

**Istio Certified Associate (ICA)**
- Service mesh architecture
- Traffic management
- Security policies
- Troubleshooting

**CKS (Certified Kubernetes Security)**
- Network policies with Istio
- mTLS implementation
- Security scanning

## 🔄 Next Steps

1. **Deploy Istio**: Run the deployment script
2. **Explore Kiali**: Visualize service topology
3. **Practice Traffic Management**: Implement canary deployments
4. **Test Security**: Configure authorization policies
5. **Monitor Performance**: Use distributed tracing
6. **Chaos Engineering**: Inject faults and observe behavior

## 🛠 Troubleshooting

### **Common Issues**
```bash
# Check sidecar injection
kubectl get pods -n hipster-shop -o wide

# Verify Istio configuration
istioctl analyze

# Check proxy configuration
istioctl proxy-config cluster <pod-name> -n hipster-shop

# View Envoy logs
kubectl logs <pod-name> -c istio-proxy -n hipster-shop
```

This service mesh implementation provides **production-grade networking, security, and observability** - essential skills for modern Kubernetes operations!
