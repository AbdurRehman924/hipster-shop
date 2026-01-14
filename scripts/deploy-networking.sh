#!/bin/bash

set -e

echo "🌐 Deploying Advanced Networking Stack..."

# Install NGINX Ingress Controller
echo "📥 Installing NGINX Ingress Controller..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.type=LoadBalancer \
  --wait

# Label namespace for network policies
kubectl label namespace ingress-nginx name=ingress-nginx --overwrite
kubectl label namespace monitoring name=monitoring --overwrite 2>/dev/null || true

# Install cert-manager
echo "🔐 Installing cert-manager..."
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true \
  --wait

# Wait for cert-manager webhook
echo "⏳ Waiting for cert-manager webhook..."
kubectl wait --for=condition=available --timeout=300s deployment/cert-manager-webhook -n cert-manager

# Get DigitalOcean token for external-dns
if [ -z "$DO_TOKEN" ]; then
  echo "⚠️  DO_TOKEN not set. Reading from terraform.tfvars..."
  DO_TOKEN=$(grep 'do_token' terraform-infra/terraform.tfvars | cut -d'"' -f2)
fi

# Create secret for external-dns
echo "🔑 Creating DigitalOcean DNS secret..."
kubectl create secret generic digitalocean-dns \
  --from-literal=access-token=$DO_TOKEN \
  --namespace=kube-system \
  --dry-run=client -o yaml | kubectl apply -f -

# Apply cert-manager issuers
echo "📜 Applying cert-manager issuers..."
echo "⚠️  IMPORTANT: Edit k8s/networking/cert-manager.yaml and replace 'your-email@example.com' with your email"
read -p "Press enter when you've updated the email address..."
kubectl apply -f k8s/networking/cert-manager.yaml

# Deploy external-dns
echo "🌍 Deploying external-dns..."
echo "⚠️  IMPORTANT: Edit k8s/networking/external-dns.yaml and replace 'yourdomain.com' with your domain"
read -p "Press enter when you've updated the domain..."
kubectl apply -f k8s/networking/external-dns.yaml

# Apply network policies
echo "🔒 Applying network policies..."
kubectl apply -f k8s/networking/network-policies.yaml

# Update frontend service to ClusterIP
echo "🔄 Updating hipster-shop to use Ingress..."
helm upgrade hipster-shop k8s/helm/hipster-shop \
  --namespace hipster-shop \
  --reuse-values \
  --set loadbalancer.enabled=false \
  --set loadbalancer.type=ClusterIP

# Apply ingress resources
echo "🚪 Applying ingress resources..."
echo "⚠️  IMPORTANT: Edit k8s/networking/ingress.yaml and replace 'yourdomain.com' with your domain"
read -p "Press enter when you've updated the domains..."
kubectl apply -f k8s/networking/ingress.yaml

# Create basic auth for monitoring (optional)
echo "🔐 Creating basic auth for monitoring..."
htpasswd -bc auth admin admin123 2>/dev/null || echo "admin:$(openssl passwd -apr1 admin123)" > auth
kubectl create secret generic monitoring-basic-auth \
  --from-file=auth \
  --namespace=monitoring \
  --dry-run=client -o yaml | kubectl apply -f -
rm -f auth

# Get ingress IP
echo "⏳ Waiting for ingress controller to get external IP..."
sleep 10
INGRESS_IP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo ""
echo "✅ Advanced Networking deployed successfully!"
echo ""
echo "📋 Next Steps:"
echo "1. Point your DNS records to: $INGRESS_IP"
echo "   - hipster-shop.yourdomain.com → $INGRESS_IP"
echo "   - grafana.yourdomain.com → $INGRESS_IP"
echo "   - prometheus.yourdomain.com → $INGRESS_IP"
echo ""
echo "2. Wait for DNS propagation (5-10 minutes)"
echo ""
echo "3. Cert-manager will automatically provision TLS certificates"
echo ""
echo "4. Verify network policies:"
echo "   kubectl get networkpolicies -n hipster-shop"
echo ""
echo "5. Check certificate status:"
echo "   kubectl get certificates -n hipster-shop"
echo "   kubectl describe certificate hipster-shop-tls -n hipster-shop"
echo ""
echo "6. Test connectivity:"
echo "   curl https://hipster-shop.yourdomain.com"
echo ""
echo "📚 Learn more:"
echo "- Network Policies: kubectl describe networkpolicy -n hipster-shop"
echo "- Ingress: kubectl describe ingress -n hipster-shop"
echo "- Certificates: kubectl get certificaterequests -A"
