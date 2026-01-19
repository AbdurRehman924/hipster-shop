#!/bin/bash
set -e

echo "💾 Deploying Backup & Disaster Recovery with Velero..."

# Check prerequisites
if [ -z "$DO_SPACES_KEY" ] || [ -z "$DO_SPACES_SECRET" ]; then
    echo "❌ Please set DigitalOcean Spaces credentials:"
    echo "export DO_SPACES_KEY=your_spaces_key"
    echo "export DO_SPACES_SECRET=your_spaces_secret"
    exit 1
fi

# Create DigitalOcean Spaces bucket (if not exists)
echo "🪣 Creating DigitalOcean Spaces bucket..."
doctl spaces create hipster-shop-backups --region nyc3 || echo "Bucket may already exist"

# Create velero namespace
kubectl create namespace velero --dry-run=client -o yaml | kubectl apply -f -

# Create credentials secret
echo "🔑 Creating Velero credentials..."
cat > /tmp/credentials-velero << EOF
[default]
aws_access_key_id=$DO_SPACES_KEY
aws_secret_access_key=$DO_SPACES_SECRET
EOF

kubectl create secret generic cloud-credentials \
    --namespace velero \
    --from-file cloud=/tmp/credentials-velero \
    --dry-run=client -o yaml | kubectl apply -f -

rm /tmp/credentials-velero

# Add Velero Helm repo
helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts/
helm repo update

# Install Velero
echo "📦 Installing Velero..."
helm upgrade --install velero vmware-tanzu/velero \
    --namespace velero \
    --values k8s/helm/backup/velero-values.yaml \
    --wait

# Apply backup schedules
echo "📅 Setting up backup schedules..."
kubectl apply -f k8s/backup/backup-schedules.yaml

# Apply backup hooks
echo "🪝 Configuring backup hooks..."
kubectl apply -f k8s/backup/backup-hooks.yaml

# Apply DR runbook
echo "📋 Installing DR runbook..."
kubectl apply -f k8s/backup/dr-runbook.yaml

# Apply monitoring
echo "📊 Setting up backup monitoring..."
kubectl apply -f k8s/backup/backup-monitoring.yaml
kubectl apply -f k8s/backup/backup-dashboard.yaml

# Wait for Velero to be ready
echo "⏳ Waiting for Velero to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/velero -n velero

echo "✅ Backup & Disaster Recovery deployed successfully!"
echo ""
echo "🔍 Check Velero status:"
echo "velero get backups"
echo "velero get schedules"
echo ""
echo "📊 View backup dashboard in Grafana"
echo ""
echo "🧪 Test backup:"
echo "velero backup create test-backup --include-namespaces hipster-shop"
