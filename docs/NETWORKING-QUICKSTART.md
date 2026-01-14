# Advanced Networking - Quick Reference

## 🚀 Deployment Commands

```bash
# Deploy entire networking stack
./scripts/deploy-networking.sh

# Or deploy components individually:

# 1. NGINX Ingress
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace

# 2. Cert-Manager
helm upgrade --install cert-manager jetstack/cert-manager \
  --repo https://charts.jetstack.io \
  --namespace cert-manager --create-namespace \
  --set installCRDs=true

# 3. External DNS
kubectl apply -f k8s/networking/external-dns.yaml

# 4. Network Policies
kubectl apply -f k8s/networking/network-policies.yaml

# 5. Ingress Resources
kubectl apply -f k8s/networking/ingress.yaml
```

## 🔍 Verification Commands

```bash
# Check all networking components
kubectl get pods -n ingress-nginx
kubectl get pods -n cert-manager
kubectl get deployment external-dns -n kube-system
kubectl get networkpolicies -n hipster-shop
kubectl get ingress -A
kubectl get certificates -A

# Get ingress IP
kubectl get svc ingress-nginx-controller -n ingress-nginx

# Test network policies
./scripts/test-network-policies.sh

# Check certificate status
kubectl describe certificate hipster-shop-tls -n hipster-shop

# View external-dns logs
kubectl logs -n kube-system deployment/external-dns -f
```

## 🐛 Troubleshooting

```bash
# Certificate issues
kubectl get certificaterequest -n hipster-shop
kubectl get challenges -A
kubectl logs -n cert-manager deployment/cert-manager

# Ingress issues
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller
kubectl describe ingress -n hipster-shop

# DNS issues
kubectl logs -n kube-system deployment/external-dns
doctl compute domain records list yourdomain.com

# Network policy issues
kubectl describe networkpolicy -n hipster-shop
```

## 📝 Configuration Checklist

Before deploying, update these files:

- [ ] `k8s/networking/cert-manager.yaml` - Replace email address
- [ ] `k8s/networking/external-dns.yaml` - Replace domain
- [ ] `k8s/networking/ingress.yaml` - Replace all domain references
- [ ] Set `DO_TOKEN` environment variable
- [ ] Ensure domain is managed by DigitalOcean

## 🔐 Security Features

- ✅ Zero-trust network policies (default deny)
- ✅ Automatic TLS certificates
- ✅ Basic auth for monitoring endpoints
- ✅ HTTPS redirect enabled
- ✅ Single ingress point (reduced attack surface)

## 💰 Cost Savings

| Before | After | Savings |
|--------|-------|---------|
| 3 LoadBalancers ($36/mo) | 1 LoadBalancer ($12/mo) | $24/mo (67%) |

## 🎯 Learning Outcomes

After implementing this, you'll understand:
- Kubernetes network security model
- Ingress controllers and routing
- TLS certificate automation
- DNS automation in Kubernetes
- Production networking patterns
