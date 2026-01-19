#!/bin/bash
set -e

echo "🚨 DISASTER RECOVERY PROCEDURE"
echo "=============================="
echo ""

# Check if this is really needed
read -p "⚠️  Are you sure you need to perform disaster recovery? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Disaster recovery cancelled."
    exit 0
fi

echo ""
echo "📋 Step 1: Assess Current Situation"
echo "-----------------------------------"

# Check cluster status
echo "🔍 Checking cluster status..."
kubectl get nodes || echo "❌ Cannot connect to cluster"
kubectl get pods --all-namespaces | grep -E "(Error|CrashLoopBackOff|Pending)" || echo "✅ No obvious pod issues"

echo ""
echo "📋 Step 2: List Available Backups"
echo "---------------------------------"

# List recent backups
echo "📦 Available backups:"
velero backup get | head -20

echo ""
read -p "📝 Enter the backup name to restore from: " BACKUP_NAME

if [ -z "$BACKUP_NAME" ]; then
    echo "❌ No backup name provided. Exiting."
    exit 1
fi

# Verify backup exists
if ! velero backup describe "$BACKUP_NAME" &>/dev/null; then
    echo "❌ Backup '$BACKUP_NAME' not found. Exiting."
    exit 1
fi

echo ""
echo "📋 Step 3: Backup Information"
echo "-----------------------------"
velero backup describe "$BACKUP_NAME"

echo ""
read -p "🔄 Proceed with restore from '$BACKUP_NAME'? (yes/no): " proceed
if [ "$proceed" != "yes" ]; then
    echo "Restore cancelled."
    exit 0
fi

echo ""
echo "📋 Step 4: Performing Restore"
echo "-----------------------------"

RESTORE_NAME="dr-restore-$(date +%Y%m%d-%H%M%S)"

# Perform the restore
echo "🔄 Starting restore: $RESTORE_NAME"
velero restore create "$RESTORE_NAME" \
    --from-backup "$BACKUP_NAME" \
    --wait

echo ""
echo "📋 Step 5: Verify Restore"
echo "-------------------------"

# Check restore status
echo "📊 Restore status:"
velero restore describe "$RESTORE_NAME"

echo ""
echo "🔍 Checking application status..."

# Check hipster-shop
echo "🛍️  Hipster Shop status:"
kubectl get pods -n hipster-shop
kubectl get svc -n hipster-shop

# Check monitoring
echo "📊 Monitoring status:"
kubectl get pods -n monitoring

echo ""
echo "📋 Step 6: Application Health Check"
echo "-----------------------------------"

# Wait for pods to be ready
echo "⏳ Waiting for pods to be ready..."
kubectl wait --for=condition=Ready pods --all -n hipster-shop --timeout=300s || echo "⚠️  Some pods may still be starting"

# Test frontend connectivity
echo "🌐 Testing frontend connectivity..."
if kubectl get svc frontend -n hipster-shop &>/dev/null; then
    echo "✅ Frontend service exists"
    echo "🔗 Test with: kubectl port-forward svc/frontend 8080:8080 -n hipster-shop"
else
    echo "❌ Frontend service not found"
fi

echo ""
echo "📋 Step 7: Post-Recovery Actions"
echo "--------------------------------"

echo "✅ Disaster recovery completed!"
echo ""
echo "🔍 Next steps:"
echo "1. Test all application functionality"
echo "2. Verify monitoring and alerting"
echo "3. Check data integrity"
echo "4. Update incident documentation"
echo "5. Schedule post-incident review"
echo ""
echo "📊 Monitor recovery:"
echo "kubectl get pods --all-namespaces"
echo "kubectl port-forward svc/frontend 8080:8080 -n hipster-shop"
echo "kubectl port-forward svc/grafana 3000:80 -n monitoring"
