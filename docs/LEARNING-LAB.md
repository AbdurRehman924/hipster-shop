# Kubernetes Learning Lab

This monitoring stack provides hands-on experience with essential Kubernetes observability tools.

## 🎯 Learning Objectives

### 1. **Observability Fundamentals**
- Metrics collection with Prometheus
- Visualization with Grafana
- Service discovery in Kubernetes
- Alert management

### 2. **Practical Skills**
- Writing PromQL queries
- Creating custom dashboards
- Setting up monitoring for microservices
- Understanding SLIs/SLOs

## 🚀 Quick Start

```bash
# Deploy monitoring stack
./scripts/deploy-monitoring.sh

# Check deployment status
kubectl get pods -n monitoring
```

## 📊 What You'll Monitor

### Application Metrics
- **Request Rate**: Requests per second across services
- **Response Time**: Latency percentiles (p50, p95, p99)
- **Error Rate**: HTTP 4xx/5xx responses
- **Saturation**: CPU/Memory usage

### Infrastructure Metrics
- **Node Resources**: CPU, memory, disk usage
- **Pod Health**: Restart counts, ready status
- **Network**: Traffic between services

## 🔍 Key Learning Exercises

### Exercise 1: Basic Queries
```promql
# Total requests per second
rate(http_requests_total[5m])

# 95th percentile response time
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# Error rate percentage
rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m]) * 100
```

### Exercise 2: Service-Specific Monitoring
```promql
# Frontend service requests
rate(http_requests_total{service="frontend"}[5m])

# Cart service errors
increase(http_requests_total{service="cartservice",status=~"5.."}[1h])
```

### Exercise 3: Resource Monitoring
```promql
# Pod CPU usage
rate(container_cpu_usage_seconds_total[5m])

# Memory usage percentage
container_memory_usage_bytes / container_spec_memory_limit_bytes * 100
```

## 🎨 Dashboard Creation

### Custom Dashboard Panels
1. **Golden Signals Dashboard**
   - Latency, Traffic, Errors, Saturation
2. **Service Map**
   - Request flow between microservices
3. **Infrastructure Overview**
   - Cluster resource utilization

## 🚨 Alerting Rules

Learn to create alerts for:
- High error rates (>5%)
- Slow response times (>500ms p95)
- Pod restarts
- Resource exhaustion

## 📚 Advanced Topics

### Service Mesh Integration
- Istio metrics collection
- Distributed tracing with Jaeger
- Traffic policies and observability

### Custom Metrics
- Application-specific metrics
- Business KPIs
- Custom exporters

## 🛠 Troubleshooting Guide

### Common Issues
1. **Metrics not appearing**: Check service discovery
2. **Dashboard empty**: Verify data source connection
3. **High cardinality**: Optimize label usage

### Debug Commands
```bash
# Check Prometheus targets
kubectl port-forward svc/prometheus 9090:9090 -n monitoring
# Visit http://localhost:9090/targets

# Check Grafana logs
kubectl logs deployment/grafana -n monitoring
```

## 🎓 Certification Prep

This lab covers topics for:
- **CKA**: Monitoring and logging
- **CKAD**: Observability and maintenance
- **CKS**: Security monitoring

## 📖 Additional Resources

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Tutorials](https://grafana.com/tutorials/)
- [Kubernetes Monitoring Best Practices](https://kubernetes.io/docs/concepts/cluster-administration/monitoring/)
- [SRE Workbook](https://sre.google/workbook/table-of-contents/)

## 🔄 Next Steps

1. Deploy the monitoring stack
2. Generate load with the loadgenerator
3. Explore metrics in Prometheus
4. Create custom Grafana dashboards
5. Set up alerting rules
6. Practice troubleshooting scenarios
