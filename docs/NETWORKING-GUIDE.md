# Advanced Networking Guide

This guide covers the advanced networking features implemented in the Hipster Shop project.

## 🎯 What You'll Learn

- **Network Policies**: Zero-trust pod-to-pod communication
- **Ingress Controller**: Centralized HTTP/HTTPS routing
- **External DNS**: Automatic DNS record management
- **Cert-Manager**: Automated TLS certificate provisioning

## 📦 Components

### 1. Network Policies
Implements zero-trust networking by default denying all traffic and explicitly allowing only required communication paths.

**Key Policies:**
- Default deny all ingress
- Frontend can access all backend services
- Backend services only accept traffic from authorized pods
- Monitoring namespace can scrape metrics

**Test Network Policies:**
```bash
# View all policies
kubectl get networkpolicies -n hipster-shop

# Describe specific policy
kubectl describe networkpolicy frontend-policy -n hipster-shop

# Test connectivity (should fail - no policy allows this)
kubectl run test-pod --image=busybox -n hipster-shop -- sleep 3600
kubectl exec -it test-pod -n hipster-shop -- wget -O- http://cartservice:7070
# Should timeout

# Test from frontend (should work)
kubectl exec -it deployment/frontend -n hipster-shop -- wget -O- http://cartservice:7070
```

### 2. NGINX Ingress Controller
Replaces individual LoadBalancers with a single ingress point.

**Benefits:**
- Single external IP for all services
- Path-based and host-based routing
- TLS termination
- Cost savings (~$12/month per LoadBalancer)

**Verify Ingress:**
```bash
# Check ingress controller
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx

# View ingress resources
kubectl get ingress -A

# Check ingress logs
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller
```

### 3. Cert-Manager
Automatically provisions and renews TLS certificates from Let's Encrypt.

**Features:**
- Automatic certificate issuance
- Auto-renewal before expiration
- HTTP-01 and DNS-01 challenge support
- Staging and production issuers

**Monitor Certificates:**
```bash
# View certificates
kubectl get certificates -A

# Check certificate details
kubectl describe certificate hipster-shop-tls -n hipster-shop

# View certificate requests
kubectl get certificaterequests -A

# Check cert-manager logs
kubectl logs -n cert-manager deployment/cert-manager
```

**Certificate Lifecycle:**
1. Ingress created with `cert-manager.io/cluster-issuer` annotation
2. Cert-manager detects and creates Certificate resource
3. ACME challenge initiated (HTTP-01 or DNS-01)
4. Let's Encrypt validates domain ownership
5. Certificate issued and stored in Secret
6. Auto-renewal 30 days before expiration

### 4. External DNS
Automatically creates DNS records for Ingress and LoadBalancer services.

**How it Works:**
1. Watches Ingress resources
2. Extracts hostnames from rules
3. Creates/updates DNS records in DigitalOcean
4. Maintains TXT records for ownership

**Verify External DNS:**
```bash
# Check external-dns logs
kubectl logs -n kube-system deployment/external-dns

# View DNS records in DigitalOcean
doctl compute domain records list yourdomain.com

# Test DNS resolution
dig hipster-shop.yourdomain.com
nslookup grafana.yourdomain.com
```

## 🚀 Deployment

### Prerequisites
1. **Domain name** registered and managed by DigitalOcean
2. **DigitalOcean API token** with DNS write access
3. **Email address** for Let's Encrypt notifications

### Step 1: Update Configuration Files

**Edit `k8s/networking/cert-manager.yaml`:**
```yaml
email: your-email@example.com  # Replace with your email
```

**Edit `k8s/networking/external-dns.yaml`:**
```yaml
- --domain-filter=yourdomain.com  # Replace with your domain
```

**Edit `k8s/networking/ingress.yaml`:**
```yaml
- host: hipster-shop.yourdomain.com  # Replace with your domain
- host: grafana.yourdomain.com
- host: prometheus.yourdomain.com
```

### Step 2: Deploy Networking Stack
```bash
# Set DigitalOcean token
export DO_TOKEN="your-do-token"

# Run deployment script
./scripts/deploy-networking.sh
```

### Step 3: Configure DNS
Point your domain to the ingress controller IP:
```bash
# Get ingress IP
kubectl get svc ingress-nginx-controller -n ingress-nginx

# Create DNS A records (or let external-dns do it automatically)
hipster-shop.yourdomain.com → INGRESS_IP
grafana.yourdomain.com → INGRESS_IP
prometheus.yourdomain.com → INGRESS_IP
```

### Step 4: Verify TLS Certificates
```bash
# Wait for certificate issuance (2-5 minutes)
kubectl get certificate -n hipster-shop -w

# Should show "Ready: True"
# Test HTTPS
curl -I https://hipster-shop.yourdomain.com
```

## 🔍 Troubleshooting

### Network Policies Not Working
```bash
# Check if CNI supports network policies
kubectl get nodes -o wide

# DigitalOcean uses Cilium - supports network policies
# Verify policies are applied
kubectl get networkpolicies -n hipster-shop

# Test connectivity
kubectl run debug --image=nicolaka/netshoot -n hipster-shop -- sleep 3600
kubectl exec -it debug -n hipster-shop -- curl http://cartservice:7070
```

### Certificate Not Issuing
```bash
# Check certificate status
kubectl describe certificate hipster-shop-tls -n hipster-shop

# Check certificate request
kubectl get certificaterequest -n hipster-shop
kubectl describe certificaterequest -n hipster-shop

# Check ACME challenge
kubectl get challenges -A
kubectl describe challenge -n hipster-shop

# Common issues:
# 1. DNS not pointing to ingress IP
# 2. Firewall blocking port 80 (HTTP-01 challenge)
# 3. Rate limiting (use staging issuer first)

# Test with staging issuer first
kubectl annotate ingress hipster-shop-ingress \
  cert-manager.io/cluster-issuer=letsencrypt-staging \
  -n hipster-shop --overwrite
```

### External DNS Not Creating Records
```bash
# Check external-dns logs
kubectl logs -n kube-system deployment/external-dns -f

# Common issues:
# 1. Invalid DO_TOKEN
# 2. Domain not managed by DigitalOcean
# 3. Insufficient permissions

# Verify token
doctl auth init --access-token $DO_TOKEN
doctl compute domain list
```

### Ingress Not Routing Traffic
```bash
# Check ingress controller logs
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller

# Verify ingress resource
kubectl describe ingress hipster-shop-ingress -n hipster-shop

# Check backend service
kubectl get svc frontend -n hipster-shop

# Test from ingress controller
kubectl exec -it -n ingress-nginx deployment/ingress-nginx-controller -- curl http://frontend.hipster-shop:8080
```

## 📊 Monitoring

### Network Policy Metrics
```promql
# Denied connections (if using Cilium)
cilium_policy_l3_denied_total

# Allowed connections
cilium_policy_l3_allowed_total
```

### Ingress Metrics
```promql
# Request rate
rate(nginx_ingress_controller_requests[5m])

# Response time
histogram_quantile(0.95, rate(nginx_ingress_controller_request_duration_seconds_bucket[5m]))

# Error rate
rate(nginx_ingress_controller_requests{status=~"5.."}[5m])
```

### Certificate Expiry
```promql
# Days until expiry
(certmanager_certificate_expiration_timestamp_seconds - time()) / 86400

# Alert if < 30 days
(certmanager_certificate_expiration_timestamp_seconds - time()) / 86400 < 30
```

## 🎓 Learning Exercises

### Exercise 1: Test Network Isolation
```bash
# Deploy a rogue pod
kubectl run attacker --image=nicolaka/netshoot -n hipster-shop -- sleep 3600

# Try to access payment service (should fail)
kubectl exec -it attacker -n hipster-shop -- curl http://paymentservice:50051

# Verify it's blocked by network policy
kubectl describe networkpolicy paymentservice-policy -n hipster-shop
```

### Exercise 2: Implement Rate Limiting
```yaml
# Add to ingress annotations
nginx.ingress.kubernetes.io/limit-rps: "10"
nginx.ingress.kubernetes.io/limit-connections: "5"
```

### Exercise 3: Add Custom Domain
```yaml
# Add new ingress rule
- host: shop.yourdomain.com
  http:
    paths:
    - path: /
      pathType: Prefix
      backend:
        service:
          name: frontend
          port:
            number: 8080
```

### Exercise 4: Implement WAF Rules
```yaml
# Add ModSecurity annotations
nginx.ingress.kubernetes.io/enable-modsecurity: "true"
nginx.ingress.kubernetes.io/enable-owasp-core-rules: "true"
```

## 🔐 Security Best Practices

1. **Network Policies**: Always start with default deny
2. **TLS**: Use production issuer only after testing with staging
3. **DNS**: Use separate API token with minimal permissions
4. **Ingress**: Enable rate limiting and WAF
5. **Monitoring**: Alert on certificate expiry and policy violations

## 💰 Cost Impact

**Before (LoadBalancers):**
- Frontend LoadBalancer: $12/month
- Grafana LoadBalancer: $12/month
- Prometheus LoadBalancer: $12/month
- **Total: $36/month**

**After (Ingress):**
- Single Ingress LoadBalancer: $12/month
- **Savings: $24/month (67% reduction)**

## 📚 Additional Resources

- [Kubernetes Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/)
- [Cert-Manager Documentation](https://cert-manager.io/docs/)
- [External DNS](https://github.com/kubernetes-sigs/external-dns)
- [Let's Encrypt Rate Limits](https://letsencrypt.org/docs/rate-limits/)

## 🔄 Next Steps

1. Deploy the networking stack
2. Configure your domain
3. Test network policies
4. Monitor certificate issuance
5. Implement rate limiting
6. Add WAF rules
7. Set up monitoring alerts
