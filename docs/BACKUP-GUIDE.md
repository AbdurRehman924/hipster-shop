# Backup & Disaster Recovery Guide

Comprehensive data protection and disaster recovery with Velero and DigitalOcean Spaces.

## 🎯 What You'll Learn

- **Automated Backups**: Scheduled cluster and application backups
- **Disaster Recovery**: Complete cluster restoration procedures
- **Data Protection**: Volume snapshots and persistent data backup
- **Business Continuity**: RTO/RPO planning and testing
- **Compliance**: Backup retention and audit trails

## 🚀 Quick Start

```bash
# Set DigitalOcean Spaces credentials
export DO_SPACES_KEY=your_spaces_key
export DO_SPACES_SECRET=your_spaces_secret

# Deploy backup solution
./scripts/deploy-backup.sh

# Test backup functionality
./scripts/test-backup.sh
```

## 📦 Backup Strategy

### Backup Schedules

#### Critical Applications (Every 6 hours)
- **Scope**: hipster-shop namespace
- **Retention**: 7 days
- **Includes**: Deployments, services, configs, secrets, PVCs
- **Volume Snapshots**: Enabled

#### Daily Backups (2 AM)
- **Scope**: All application namespaces
- **Retention**: 30 days
- **Includes**: Complete namespace backup
- **Volume Snapshots**: Enabled

#### Weekly Backups (Sunday 3 AM)
- **Scope**: Entire cluster
- **Retention**: 90 days
- **Includes**: All namespaces and cluster resources
- **Volume Snapshots**: Enabled

### Backup Components

```yaml
# Included in backups:
- Applications: hipster-shop, monitoring
- Infrastructure: istio-system, argocd
- Security: falco, trivy-system, gatekeeper-system
- Platform: kyverno, chaos-mesh, kubecost
```

## 💾 Storage Configuration

### DigitalOcean Spaces
- **Region**: NYC3
- **Bucket**: hipster-shop-backups
- **Encryption**: Server-side encryption enabled
- **Access**: Private with IAM credentials

### Volume Snapshots
- **Provider**: DigitalOcean Block Storage
- **Frequency**: With each backup
- **Retention**: Matches backup retention
- **Consistency**: Application-consistent snapshots

## 🔄 Backup Operations

### Manual Backup
```bash
# Create immediate backup
velero backup create emergency-backup \
    --include-namespaces hipster-shop,monitoring \
    --wait

# Backup specific resources
velero backup create config-backup \
    --include-resources configmaps,secrets \
    --include-namespaces hipster-shop
```

### Backup Verification
```bash
# List all backups
velero backup get

# Check backup details
velero backup describe <backup-name>

# View backup logs
velero backup logs <backup-name>
```

### Backup Monitoring
```bash
# Check backup storage
velero backup-location get

# Monitor backup metrics
kubectl port-forward svc/grafana 3000:80 -n monitoring
# Go to Backup & Disaster Recovery dashboard
```

## 🚨 Disaster Recovery

### Recovery Scenarios

#### 1. Application Failure
```bash
# Restore specific namespace
velero restore create app-restore \
    --from-backup <backup-name> \
    --include-namespaces hipster-shop
```

#### 2. Data Corruption
```bash
# Restore with volume snapshots
velero restore create data-restore \
    --from-backup <backup-name> \
    --restore-volumes=true
```

#### 3. Complete Cluster Loss
```bash
# Full cluster restore
./scripts/disaster-recovery.sh
```

### Recovery Procedures

#### Automated Recovery Script
```bash
# Interactive disaster recovery
./scripts/disaster-recovery.sh

# Follow prompts:
# 1. Assess situation
# 2. Select backup
# 3. Confirm restore
# 4. Verify recovery
# 5. Test applications
```

#### Manual Recovery Steps
```bash
# 1. List available backups
velero backup get

# 2. Create restore
velero restore create dr-restore-$(date +%s) \
    --from-backup <backup-name>

# 3. Monitor restore
velero restore get
velero restore describe <restore-name>

# 4. Verify applications
kubectl get pods --all-namespaces
kubectl port-forward svc/frontend 8080:8080 -n hipster-shop
```

## 📊 Recovery Objectives

### Recovery Time Objective (RTO)
- **Critical Applications**: < 30 minutes
- **Monitoring Stack**: < 15 minutes
- **Security Components**: < 45 minutes
- **Complete Cluster**: < 2 hours

### Recovery Point Objective (RPO)
- **Critical Data**: < 6 hours
- **Application Data**: < 24 hours
- **Configuration Data**: < 24 hours
- **Monitoring Data**: < 24 hours

## 🔍 Backup Monitoring

### Grafana Dashboard
- **Backup Success Rate**: Track backup reliability
- **Backup Duration**: Monitor backup performance
- **Storage Usage**: Track backup storage consumption
- **Recent Operations**: View backup and restore history

### Prometheus Alerts
```yaml
# Key alerts configured:
- VeleroBackupFailure: Immediate alert on backup failure
- VeleroBackupMissing: Alert if no backup in 24 hours
- VeleroRestoreFailure: Critical alert on restore failure
- VeleroBackupStorageError: Storage connectivity issues
```

### Monitoring Commands
```bash
# Check backup metrics
kubectl get servicemonitor velero-metrics -n monitoring

# View backup alerts
kubectl get prometheusrule velero-backup-alerts -n monitoring

# Check Velero logs
kubectl logs deployment/velero -n velero
```

## 🧪 Testing & Validation

### Regular Testing Schedule
- **Weekly**: Backup verification
- **Monthly**: Restore testing (non-production)
- **Quarterly**: Full disaster recovery drill
- **Annually**: Cross-region recovery test

### Test Procedures
```bash
# 1. Backup validation test
./scripts/test-backup.sh

# 2. Restore dry-run
velero restore create test-restore \
    --from-backup <backup-name> \
    --dry-run

# 3. Partial restore test
velero restore create partial-test \
    --from-backup <backup-name> \
    --include-namespaces test-namespace

# 4. Volume restore test
velero restore create volume-test \
    --from-backup <backup-name> \
    --restore-volumes=true
```

## 🔧 Advanced Configuration

### Custom Backup Hooks
```yaml
# Pre-backup hook example
annotations:
  pre.hook.backup.velero.io/command: '["/bin/bash", "-c", "pg_dump > /backup/db.sql"]'
  pre.hook.backup.velero.io/timeout: 3m

# Post-restore hook example
annotations:
  post.hook.restore.velero.io/command: '["/bin/bash", "-c", "service restart app"]'
```

### Backup Filters
```bash
# Exclude specific resources
velero backup create filtered-backup \
    --exclude-resources events,events.events.k8s.io

# Include only specific labels
velero backup create labeled-backup \
    --selector app=frontend
```

### Cross-Cluster Migration
```bash
# Backup from source cluster
velero backup create migration-backup

# Restore to target cluster
velero restore create migration-restore \
    --from-backup migration-backup
```

## 🛡️ Security & Compliance

### Encryption
- **In-Transit**: TLS encryption to DigitalOcean Spaces
- **At-Rest**: Server-side encryption in Spaces
- **Credentials**: Kubernetes secrets with RBAC

### Access Control
```yaml
# RBAC for backup operations
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: velero-backup-operator
rules:
- apiGroups: ["velero.io"]
  resources: ["backups", "restores"]
  verbs: ["get", "list", "create"]
```

### Audit Trail
- **Backup Logs**: Complete operation logging
- **Restore Logs**: Detailed restore tracking
- **Metrics**: Prometheus metrics for compliance
- **Alerts**: Automated compliance notifications

## 📋 Compliance & Reporting

### Backup Reports
```bash
# Generate backup report
velero backup get -o json | \
jq '.items[] | {name: .metadata.name, status: .status.phase, created: .metadata.creationTimestamp}'

# Storage usage report
velero backup get -o json | \
jq '.items[] | {name: .metadata.name, size: .status.totalItems}'
```

### Retention Compliance
- **Daily Backups**: 30-day retention
- **Weekly Backups**: 90-day retention
- **Critical Backups**: 7-day retention (high frequency)
- **Compliance Backups**: 7-year retention (security data)

## 🎓 Best Practices

### Backup Strategy
1. **3-2-1 Rule**: 3 copies, 2 different media, 1 offsite
2. **Regular Testing**: Test restores monthly
3. **Documentation**: Keep recovery procedures updated
4. **Monitoring**: Alert on backup failures
5. **Automation**: Minimize manual intervention

### Disaster Recovery
1. **Clear Procedures**: Document step-by-step processes
2. **Regular Drills**: Practice recovery scenarios
3. **Communication Plan**: Define incident response team
4. **Rollback Plan**: Always have a rollback strategy
5. **Post-Incident Review**: Learn from each incident

## 🚨 Emergency Contacts

### Escalation Matrix
- **Level 1**: Platform Team (immediate response)
- **Level 2**: Infrastructure Team (30 minutes)
- **Level 3**: Management (1 hour)
- **Level 4**: External Support (2 hours)

### Emergency Procedures
1. **Assess Impact**: Determine scope and severity
2. **Communicate**: Notify stakeholders
3. **Execute Recovery**: Follow documented procedures
4. **Monitor Progress**: Track recovery metrics
5. **Validate Success**: Test all functionality
6. **Document Incident**: Record lessons learned

This backup and disaster recovery implementation provides **enterprise-grade data protection** for your Kubernetes platform!
