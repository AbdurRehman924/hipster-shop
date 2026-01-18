#!/bin/bash
set -e

echo "🔒 Deploying Security Scanning & Compliance Stack..."

# Create security namespace
kubectl create namespace trivy-system --dry-run=client -o yaml | kubectl apply -f -

# Install Trivy Operator CRDs
echo "📦 Installing Trivy Operator CRDs..."
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/trivy-operator/main/deploy/static/trivy-operator.yaml

# Deploy Trivy Operator
echo "🔍 Deploying Trivy Operator..."
kubectl apply -f k8s/security/trivy-operator.yaml
kubectl apply -f k8s/security/trivy-config.yaml

# Install OPA Gatekeeper
echo "🚪 Installing OPA Gatekeeper..."
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/release-3.15/deploy/gatekeeper.yaml

# Wait for Gatekeeper to be ready
echo "⏳ Waiting for Gatekeeper to be ready..."
kubectl wait --for=condition=Ready pods --all -n gatekeeper-system --timeout=300s

# Apply Gatekeeper policies
echo "📋 Applying Gatekeeper policies..."
sleep 30  # Wait for CRDs to be established
kubectl apply -f k8s/security/gatekeeper-security-context.yaml
kubectl apply -f k8s/security/gatekeeper-allowed-repos.yaml
kubectl apply -f k8s/security/gatekeeper-policies.yaml

# Install Falco
echo "🦅 Installing Falco..."
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update

helm upgrade --install falco falcosecurity/falco \
    --namespace falco \
    --create-namespace \
    --values k8s/helm/security/falco-values.yaml \
    --wait

# Apply custom Falco rules
kubectl create configmap falco-rules-custom \
    --from-file=k8s/security/falco-rules.yaml \
    -n falco \
    --dry-run=client -o yaml | kubectl apply -f -

# Apply security dashboard
echo "📊 Adding security dashboard..."
kubectl apply -f k8s/security/security-dashboard.yaml

echo "✅ Security stack deployed successfully!"
echo ""
echo "🔍 Check vulnerability reports:"
echo "kubectl get vulnerabilityreports -A"
echo ""
echo "🚪 Check Gatekeeper constraints:"
echo "kubectl get constraints"
echo ""
echo "🦅 Check Falco events:"
echo "kubectl logs -n falco -l app.kubernetes.io/name=falco -f"
echo ""
echo "📊 View security dashboard in Grafana"
