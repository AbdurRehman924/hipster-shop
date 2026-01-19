#!/bin/bash
set -e

echo "🧪 Testing Backup & Disaster Recovery..."

# Check if Velero is installed
if ! kubectl get namespace velero &>/dev/null; then
    echo "❌ Velero not deployed. Run: ./scripts/deploy-backup.sh"
    exit 1
fi

echo "1️⃣  Testing Velero Installation..."
echo "✅ Velero namespace exists"

# Check Velero pod status
VELERO_PODS=$(kubectl get pods -n velero --no-headers | grep -c "Running" || echo "0")
if [ "$VELERO_PODS" -gt 0 ]; then
    echo "✅ Velero pods are running ($VELERO_PODS)"
    kubectl get pods -n velero
else
    echo "❌ Velero pods not running"
    kubectl get pods -n velero
fi

echo ""
echo "---"
echo ""

echo "2️⃣  Testing Backup Functionality..."

# Create a test backup
echo "📦 Creating test backup..."
velero backup create test-backup-$(date +%s) \
    --include-namespaces hipster-shop \
    --wait

# Check backup status
echo "📋 Recent backups:"
velero backup get | head -10

echo ""
echo "---"
echo ""

echo "3️⃣  Testing Backup Schedules..."
echo "📅 Active backup schedules:"
velero schedule get

# Check if schedules are working
SCHEDULES=$(velero schedule get --output json | jq -r '.items | length')
if [ "$SCHEDULES" -gt 0 ]; then
    echo "✅ Found $SCHEDULES backup schedules"
else
    echo "⚠️  No backup schedules found"
fi

echo ""
echo "---"
echo ""

echo "4️⃣  Testing Storage Connectivity..."
# Check backup storage location
velero backup-location get

BSL_STATUS=$(velero backup-location get -o json | jq -r '.items[0].status.phase' 2>/dev/null || echo "Unknown")
if [ "$BSL_STATUS" = "Available" ]; then
    echo "✅ Backup storage location is available"
else
    echo "⚠️  Backup storage location status: $BSL_STATUS"
fi

echo ""
echo "---"
echo ""

echo "5️⃣  Disaster Recovery Test (Dry Run)..."
echo "🔄 Testing restore capability..."

# Get the latest backup
LATEST_BACKUP=$(velero backup get -o json | jq -r '.items | sort_by(.metadata.creationTimestamp) | reverse | .[0].metadata.name' 2>/dev/null || echo "none")

if [ "$LATEST_BACKUP" != "none" ] && [ "$LATEST_BACKUP" != "null" ]; then
    echo "📋 Latest backup: $LATEST_BACKUP"
    
    # Dry run restore
    echo "🧪 Performing dry-run restore..."
    velero restore create test-restore-$(date +%s) \
        --from-backup "$LATEST_BACKUP" \
        --include-namespaces hipster-shop \
        --dry-run
    
    echo "✅ Dry-run restore completed successfully"
else
    echo "⚠️  No backups available for restore testing"
fi

echo ""
echo "---"
echo ""

echo "6️⃣  Monitoring Integration..."
# Check if monitoring is set up
if kubectl get servicemonitor velero-metrics -n monitoring &>/dev/null; then
    echo "✅ Velero metrics monitoring configured"
else
    echo "⚠️  Velero metrics monitoring not found"
fi

if kubectl get prometheusrule velero-backup-alerts -n monitoring &>/dev/null; then
    echo "✅ Backup alerting rules configured"
else
    echo "⚠️  Backup alerting rules not found"
fi

echo ""
echo "---"
echo ""
echo "✅ Backup & Disaster Recovery testing complete!"
echo ""
echo "📊 View backup dashboard:"
echo "kubectl port-forward svc/grafana 3000:80 -n monitoring"
echo "Then go to Dashboards > Backup & Disaster Recovery"
echo ""
echo "🔧 Useful commands:"
echo "velero backup get"
echo "velero schedule get"
echo "velero restore get"
echo "velero backup describe <backup-name>"
