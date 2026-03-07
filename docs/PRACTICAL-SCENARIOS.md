# Practical Scenarios & Problem-Solving Guide

## 🎯 Purpose
Bridge the gap between deployment knowledge and real-world operational expertise. This guide simulates actual problems DevSecOps, Platform Engineers, and SREs solve daily.

---

## 📊 PROGRESS TRACKER

**Current Level**: Beginner  
**Scenarios Completed**: 0/30  
**Last Updated**: 2026-03-07

## ⚠️ IMPORTANT: LEARNING MODE
**YOU execute all commands yourself - AI provides guidance only**
- AI will NOT run commands automatically (unless explicitly asked)
- AI provides: command explanations, context, troubleshooting help, and executes tasks when requested
- USER run: every single command to build muscle memory
- This is hands-on learning - no shortcuts!

 Implementation
- Deploy and configure components
- Hands-on execution of commands with clear explanations:
  - **Command**: The exact command to run
  - **Purpose**: What this command does
  - **Why**: Why this step is necessary
  - **Problem**: What problem does this solves
  - **Advantages**: What advantages does this gives
  - **Best Practices**: What are the best practices
- Troubleshoot issues as they arise

### Quick Stats
- 🚨 Incident Response: 0/5 complete
- 🔒 Security Operations: 0/3 complete
- 📊 Observability: 0/3 complete
- ⚙️ Platform Engineering: 0/4 complete
- 🔧 Troubleshooting: 0/3 complete
- 🎭 Chaos Engineering: 0/2 complete
- 📈 Performance & Cost: 0/2 complete
- 🔄 Daily Operations: 0/4 complete
- 🎯 Advanced Scenarios: 0/4 complete

### Skill Progression
- [ ] **Level 1: Beginner** (0/10 scenarios) - Basic troubleshooting
- [ ] **Level 2: Intermediate** (0/10 scenarios) - Independent problem-solving
- [ ] **Level 3: Advanced** (0/10 scenarios) - Architecture & optimization

---

## 📋 How to Use This Guide
1. **Don't skip scenarios** - Each builds practical muscle memory
2. **Time yourself** - Real incidents have time pressure
3. **Document your approach** - Write down what you tried and why
4. **No AI shortcuts initially** - Try solving first, then ask for help
5. **Update checkboxes** - Mark [x] when complete
6. **Track your time** - Record actual time taken vs target

---

## 🚨 INCIDENT RESPONSE SCENARIOS (Level 1)

### ✅ Progress: 0/5 Complete

---

### [ ] Scenario 1: Production Down - Frontend Unreachable
**Severity**: P0 (Critical)  
**Time Limit**: 15 minutes  
**Status**: Not Started  
**Actual Time**: ___ minutes  
**Attempts**: 0

**Situation**: 
- Users report the website is down
- External IP not responding
- No recent deployments

**Your Tasks**:
1. [ ] Check if the frontend pods are running
2. [ ] Verify the LoadBalancer service has an external IP
3. [ ] Check pod logs for errors
4. [ ] Verify Istio gateway configuration
5. [ ] Test internal service connectivity
6. [ ] Check recent events in the namespace

**Success Criteria**: Identify the root cause and restore service

**Solution Notes** (fill after completing):
```
Root Cause: 


Commands Used:


Lessons Learned:


```

**Real-World Skills**: Incident triage, systematic debugging, service mesh troubleshooting

---

### [ ] Scenario 2: Memory Leak Detection
**Severity**: P1 (High)  
**Time Limit**: 30 minutes  
**Status**: Not Started  
**Actual Time**: ___ minutes  
**Attempts**: 0

**Situation**:
- Grafana shows memory usage climbing steadily for `cartservice`
- Pod has restarted 3 times in the last hour
- Users report intermittent cart issues

**Your Tasks**:
1. [ ] Check current memory usage via Prometheus queries
2. [ ] Review HPA/VPA configurations
3. [ ] Analyze pod restart patterns
4. [ ] Check if OOMKilled events exist
5. [ ] Review resource limits vs requests
6. [ ] Examine Grafana memory trends over 24 hours
7. [ ] Check if memory leak alerts fired

**Success Criteria**: Identify if it's a genuine leak or misconfigured limits

**Solution Notes** (fill after completing):
```
Root Cause: 


Commands Used:


Lessons Learned:


```

**Real-World Skills**: Performance analysis, resource optimization, metrics interpretation

---

### [ ] Scenario 3: Certificate Expiration Alert
**Severity**: P1 (High)  
**Time Limit**: 20 minutes  
**Status**: Not Started  
**Actual Time**: ___ minutes  
**Attempts**: 0

**Situation**:
- AlertManager fires: "TLS certificate expiring in 7 days"
- mTLS communication between services at risk
- Need to rotate certificates without downtime

**Your Tasks**:
1. [ ] Identify which certificates are expiring
2. [ ] Check Istio certificate management
3. [ ] Verify cert-manager (if installed) or manual cert rotation process
4. [ ] Plan zero-downtime certificate rotation
5. [ ] Test mTLS after rotation

**Success Criteria**: Rotate certificates without service disruption

**Solution Notes** (fill after completing):
```
Root Cause: 


Commands Used:


Lessons Learned:


```

**Real-World Skills**: Certificate management, zero-downtime operations, security maintenance

---

### [ ] Scenario 4: Disk Space Crisis
**Severity**: P0 (Critical)  
**Time Limit**: 10 minutes  
**Status**: Not Started  
**Actual Time**: ___ minutes  
**Attempts**: 0

**Situation**:
- Prometheus pod in CrashLoopBackOff
- Logs show: "no space left on device"
- Monitoring is down, blind to other issues

**Your Tasks**:
1. [ ] Check PVC usage for Prometheus
2. [ ] Identify what's consuming space (WAL, chunks, etc.)
3. [ ] Temporarily increase retention or storage
4. [ ] Clean up old data if possible
5. [ ] Implement long-term solution

**Success Criteria**: Restore Prometheus and prevent recurrence

**Solution Notes** (fill after completing):
```
Root Cause: 


Commands Used:


Lessons Learned:


```

**Real-World Skills**: Storage management, quick decision-making under pressure

---

### [ ] Scenario 5: Cascading Failure
**Severity**: P0 (Critical)  
**Time Limit**: 20 minutes  
**Status**: Not Started  
**Actual Time**: ___ minutes  
**Attempts**: 0

**Situation**:
- `productcatalogservice` is slow (5s response time)
- `frontend` timing out waiting for product catalog
- `recommendationservice` also affected
- Circuit breakers not triggering

**Your Tasks**:
1. [ ] Identify the root cause service
2. [ ] Check Jaeger traces for bottlenecks
3. [ ] Verify circuit breaker configuration
4. [ ] Check if rate limiting is working
5. [ ] Implement emergency traffic shedding
6. [ ] Scale affected services

**Success Criteria**: Stop the cascade and restore normal operation

**Solution Notes** (fill after completing):
```
Root Cause: 


Commands Used:


Lessons Learned:


```

**Real-World Skills**: Distributed systems debugging, traffic management, chaos mitigation

---

## 🔒 SECURITY SCENARIOS (Level 1)

### ✅ Progress: 0/3 Complete

---

### [ ] Scenario 6: Suspicious Runtime Activity
**Severity**: P1 (High)  
**Time Limit**: 15 minutes  
**Status**: Not Started  
**Actual Time**: ___ minutes  
**Attempts**: 0

**Situation**:
- Falco alert: "Shell spawned in container"
- Pod: `emailservice-7d8f9c-xk2p9`
- No deployments or maintenance scheduled

**Your Tasks**:
1. [ ] Check Falco logs for exact command executed
2. [ ] Identify if it's legitimate (init script) or malicious
3. [ ] Inspect pod for unauthorized processes
4. [ ] Check network connections from the pod
5. [ ] Review recent image changes
6. [ ] Quarantine pod if necessary (cordon node, delete pod)

**Success Criteria**: Determine if breach occurred and contain it

**Solution Notes**:
```
Root Cause: 


Commands Used:


Lessons Learned:


```

**Real-World Skills**: Security incident response, forensics, threat assessment

---

### [ ] Scenario 7: Vulnerability Remediation
**Severity**: P2 (Medium)  
**Time Limit**: 2 hours  
**Status**: Not Started  
**Actual Time**: ___ minutes  
**Attempts**: 0

**Situation**:
- Trivy reports 15 CRITICAL CVEs in `emailservice` image
- CVE-2024-12345 allows remote code execution
- Need to patch without breaking functionality

**Your Tasks**:
1. [ ] Review Trivy scan results
2. [ ] Identify which base image layer has vulnerabilities
3. [ ] Check if updated base image exists
4. [ ] Rebuild image with patched dependencies
5. [ ] Test in staging (simulate with different namespace)
6. [ ] Deploy via GitOps
7. [ ] Verify vulnerability is resolved

**Success Criteria**: Reduce critical CVEs to zero

**Solution Notes**:
```
Root Cause: 


Commands Used:


Lessons Learned:


```

**Real-World Skills**: Vulnerability management, image hardening, safe deployment practices

---

### [ ] Scenario 8: Network Policy Breach
**Severity**: P1 (High)  
**Time Limit**: 30 minutes  
**Status**: Not Started  
**Actual Time**: ___ minutes  
**Attempts**: 0

**Situation**:
- Security audit shows `frontend` can directly access `paymentservice`
- Should only go through `checkoutservice`
- Network policies exist but not working

**Your Tasks**:
1. [ ] Review current network policies
2. [ ] Test connectivity between pods
3. [ ] Identify policy gaps or misconfigurations
4. [ ] Fix network policies
5. [ ] Verify isolation with `kubectl exec` tests
6. [ ] Ensure legitimate traffic still flows

**Success Criteria**: Enforce proper network segmentation

**Solution Notes**:
```
Root Cause: 


Commands Used:


Lessons Learned:


```

**Real-World Skills**: Network security, policy debugging, zero-trust implementation

---

## 📊 OBSERVABILITY SCENARIOS (Level 2)

### ✅ Progress: 0/3 Complete

---

### [ ] Scenario 9: Missing Metrics
**Severity**: P2 (Medium)  
**Time Limit**: 45 minutes  
**Status**: Not Started  
**Actual Time**: ___ minutes  
**Attempts**: 0

**Situation**:
- Grafana dashboard shows "No data" for `recommendationservice`
- Prometheus targets page shows service as "DOWN"
- Service is running and responding to requests

**Your Tasks**:
1. [ ] Check if service has metrics endpoint
2. [ ] Verify ServiceMonitor or PodMonitor exists
3. [ ] Check Prometheus scrape config
4. [ ] Test metrics endpoint manually
5. [ ] Review Prometheus logs for scrape errors
6. [ ] Fix configuration and verify data flow

**Success Criteria**: Metrics appearing in Grafana

**Solution Notes**:
```
Root Cause: 


Commands Used:


Lessons Learned:


```

**Real-World Skills**: Metrics pipeline debugging, Prometheus configuration

---

### [ ] Scenario 10: Alert Fatigue
**Severity**: P3 (Low)  
**Time Limit**: 1 hour  
**Status**: Not Started  
**Actual Time**: ___ minutes  
**Attempts**: 0

**Situation**:
- Slack channel flooded with 50+ alerts per hour
- Most are false positives or low priority
- Team ignoring critical alerts

**Your Tasks**:
1. [ ] Analyze alert patterns over 24 hours
2. [ ] Identify noisy alerts
3. [ ] Tune alert thresholds
4. [ ] Implement alert grouping/inhibition
5. [ ] Add severity labels
6. [ ] Create runbooks for common alerts

**Success Criteria**: Reduce alerts to <10 per day, all actionable

**Solution Notes**:
```
Root Cause: 


Commands Used:


Lessons Learned:


```

**Real-World Skills**: Alert engineering, SRE best practices, on-call optimization

---

### [ ] Scenario 11: Trace Investigation
**Severity**: P2 (Medium)  
**Time Limit**: 30 minutes  
**Status**: Not Started  
**Actual Time**: ___ minutes  
**Attempts**: 0

**Situation**:
- User reports checkout taking 15+ seconds
- Should complete in <3 seconds
- Need to identify bottleneck

**Your Tasks**:
1. [ ] Find traces for checkout operation in Jaeger
2. [ ] Identify slowest span
3. [ ] Check if it's network, CPU, or external dependency
4. [ ] Correlate with Prometheus metrics
5. [ ] Check Loki logs for errors during slow period
6. [ ] Propose optimization

**Success Criteria**: Pinpoint exact bottleneck service/operation

**Solution Notes**:
```
Root Cause: 


Commands Used:


Lessons Learned:


```

**Real-World Skills**: Distributed tracing, performance analysis, correlation

---

## ⚙️ PLATFORM ENGINEERING SCENARIOS (Level 2)

### ✅ Progress: 0/4 Complete

---

### [ ] Scenario 12: GitOps Sync Failure
**Severity**: P2 (Medium)  
**Time Limit**: 20 minutes  
**Status**: Not Started  
**Actual Time**: ___ minutes  
**Attempts**: 0

**Situation**:
- ArgoCD shows application as "OutOfSync"
- Manual sync fails with error
- Git repo has recent changes

**Your Tasks**:
1. [ ] Check ArgoCD application status
2. [ ] Review sync error messages
3. [ ] Validate Kubernetes manifests
4. [ ] Check for resource conflicts
5. [ ] Resolve sync issues
6. [ ] Verify auto-sync resumes

**Success Criteria**: Application synced and healthy

**Solution Notes**:
```
Root Cause: 


Commands Used:


Lessons Learned:


```

**Real-World Skills**: GitOps troubleshooting, manifest validation

---

### [ ] Scenario 13: Autoscaling Not Working
**Severity**: P2 (Medium)  
**Time Limit**: 30 minutes  
**Status**: Not Started  
**Actual Time**: ___ minutes  
**Attempts**: 0

**Situation**:
- Load test shows `frontend` at 90% CPU
- HPA configured but not scaling
- Still at 2 replicas (should scale to 10)

**Your Tasks**:
1. [ ] Check HPA status and conditions
2. [ ] Verify metrics-server is running
3. [ ] Check if resource requests are set
4. [ ] Review HPA events
5. [ ] Test manual scaling
6. [ ] Fix HPA configuration

**Success Criteria**: HPA scales pods based on load

**Solution Notes**:
```
Root Cause: 


Commands Used:


Lessons Learned:


```

**Real-World Skills**: Autoscaling debugging, Kubernetes resource management

---

### [ ] Scenario 14: Backup Restoration Test
**Severity**: P2 (Medium)  
**Time Limit**: 45 minutes  
**Status**: Not Started  
**Actual Time**: ___ minutes  
**Attempts**: 0

**Situation**:
- Quarterly DR drill
- Simulate complete namespace deletion
- Restore from Velero backup

**Your Tasks**:
1. [ ] Create fresh backup
2. [ ] Delete `hipster-shop` namespace
3. [ ] Restore from backup
4. [ ] Verify all services running
5. [ ] Test application functionality
6. [ ] Document RTO/RPO
7. [ ] Identify any gaps in backup strategy

**Success Criteria**: Full restoration with <5 minute RTO

**Solution Notes**:
```
Root Cause: 


Commands Used:


Lessons Learned:


```

**Real-World Skills**: Disaster recovery, backup validation, business continuity

---

### [ ] Scenario 15: Multi-Service Deployment
**Severity**: P2 (Medium)  
**Time Limit**: 1 hour  
**Status**: Not Started  
**Actual Time**: ___ minutes  
**Attempts**: 0

**Situation**:
- Need to deploy new versions of 3 services simultaneously
- Must maintain zero downtime
- Rollback plan required

**Your Tasks**:
1. [ ] Update manifests in Git
2. [ ] Configure progressive rollout (canary or blue-green)
3. [ ] Monitor deployment via ArgoCD
4. [ ] Watch metrics during rollout
5. [ ] Verify health checks passing
6. [ ] Prepare rollback procedure

**Success Criteria**: All services updated with zero errors

**Solution Notes**:
```
Root Cause: 


Commands Used:


Lessons Learned:


```

**Real-World Skills**: Safe deployment practices, rollout strategies

---

## 🔧 TROUBLESHOOTING SCENARIOS (Level 2)

### ✅ Progress: 0/3 Complete

---

### [ ] Scenario 16: DNS Resolution Failure
**Severity**: P1 (High)  
**Time Limit**: 20 minutes  
**Status**: Not Started  
**Actual Time**: ___ minutes  
**Attempts**: 0

**Situation**:
- `frontend` logs show: "failed to resolve productcatalogservice"
- Service exists and pods are running
- Intermittent failures

**Your Tasks**:
1. [ ] Test DNS resolution from frontend pod
2. [ ] Check CoreDNS pods status
3. [ ] Verify service DNS records
4. [ ] Check network policies blocking DNS
5. [ ] Review Istio sidecar DNS configuration
6. [ ] Fix resolution issues

**Success Criteria**: Consistent DNS resolution

**Solution Notes**:
```
Root Cause: 


Commands Used:


Lessons Learned:


```

**Real-World Skills**: DNS debugging, Kubernetes networking, service discovery

---

### [ ] Scenario 17: Image Pull Errors
**Severity**: P1 (High)  
**Time Limit**: 15 minutes  
**Status**: Not Started  
**Actual Time**: ___ minutes  
**Attempts**: 0

**Situation**:
- New deployment stuck: "ImagePullBackOff"
- Image exists in ACR
- Other services pulling images fine

**Your Tasks**:
1. [ ] Check pod events
2. [ ] Verify image name and tag
3. [ ] Check ACR credentials
4. [ ] Test manual image pull
5. [ ] Review imagePullSecrets
6. [ ] Fix authentication/configuration

**Success Criteria**: Pod successfully pulls image and starts

**Solution Notes**:
```
Root Cause: 


Commands Used:


Lessons Learned:


```

**Real-World Skills**: Container registry troubleshooting, authentication debugging

---

### [ ] Scenario 18: Persistent Volume Issues
**Severity**: P1 (High)  
**Time Limit**: 25 minutes  
**Status**: Not Started  
**Actual Time**: ___ minutes  
**Attempts**: 0

**Situation**:
- Prometheus pod stuck in "Pending"
- Events show: "FailedScheduling: no persistent volumes available"
- PVC exists but not bound

**Your Tasks**:
1. [ ] Check PVC status
2. [ ] Review PV availability
3. [ ] Check storage class
4. [ ] Verify Azure disk provisioning
5. [ ] Check node affinity/taints
6. [ ] Resolve binding issues

**Success Criteria**: PVC bound and pod running

**Solution Notes**:
```
Root Cause: 


Commands Used:


Lessons Learned:


```

**Real-World Skills**: Storage troubleshooting, cloud provider integration

---

## 🎭 CHAOS ENGINEERING SCENARIOS (Level 2)

### ✅ Progress: 0/2 Complete

---

### [ ] Scenario 19: Pod Failure Simulation
**Severity**: P3 (Low - Controlled)  
**Time Limit**: 30 minutes  
**Status**: Not Started  
**Actual Time**: ___ minutes  
**Attempts**: 0

**Situation**:
- Test platform resilience
- Randomly delete pods and observe recovery

**Your Tasks**:
1. [ ] Delete random backend service pod
2. [ ] Monitor service availability
3. [ ] Check if HPA responds
4. [ ] Verify circuit breakers activate
5. [ ] Measure recovery time
6. [ ] Document weaknesses found

**Success Criteria**: System self-heals within 30 seconds

**Solution Notes**:
```
Root Cause: 


Commands Used:


Lessons Learned:


```

**Real-World Skills**: Resilience testing, chaos engineering, observability

---

### [ ] Scenario 20: Network Latency Injection
**Severity**: P3 (Low - Controlled)  
**Time Limit**: 45 minutes  
**Status**: Not Started  
**Actual Time**: ___ minutes  
**Attempts**: 0

**Situation**:
- Test how system handles slow dependencies
- Inject 2s latency to `productcatalogservice`

**Your Tasks**:
1. [ ] Use Istio fault injection
2. [ ] Monitor frontend response times
3. [ ] Check if timeouts are appropriate
4. [ ] Verify circuit breakers trigger
5. [ ] Analyze Jaeger traces
6. [ ] Tune timeout/retry policies

**Success Criteria**: System degrades gracefully, no cascading failures

**Solution Notes**:
```
Root Cause: 


Commands Used:


Lessons Learned:


```

**Real-World Skills**: Fault injection, resilience patterns, SRE practices

---

## 📈 PERFORMANCE & COST OPTIMIZATION (Level 3)

### ✅ Progress: 0/2 Complete

---

### [ ] Scenario 21: High Latency Investigation
**Severity**: P2 (Medium)  
**Time Limit**: 1 hour  
**Status**: Not Started  
**Actual Time**: ___ minutes  
**Attempts**: 0

**Situation**:
- P95 latency increased from 200ms to 2s
- No code changes deployed
- Affects all services

**Your Tasks**:
1. [ ] Check Prometheus for resource saturation
2. [ ] Review Jaeger traces for slow spans
3. [ ] Check node resource usage
4. [ ] Verify network policies not blocking traffic
5. [ ] Check Istio proxy overhead
6. [ ] Identify and fix bottleneck

**Success Criteria**: Restore P95 latency to <500ms

**Solution Notes**:
```
Root Cause: 


Commands Used:


Lessons Learned:


```

**Real-World Skills**: Performance analysis, distributed systems debugging

---

### [ ] Scenario 22: Cost Optimization
**Severity**: P3 (Low)  
**Time Limit**: 2 hours  
**Status**: Not Started  
**Actual Time**: ___ minutes  
**Attempts**: 0

**Situation**:
- Azure bill increased 40% this month
- Need to reduce costs without impacting performance

**Your Tasks**:
1. [ ] Analyze resource requests vs actual usage
2. [ ] Identify over-provisioned services
3. [ ] Review VPA recommendations
4. [ ] Check for unused PVCs
5. [ ] Optimize node pool sizing
6. [ ] Implement resource right-sizing

**Success Criteria**: Reduce costs by 20% while maintaining SLOs

**Solution Notes**:
```
Root Cause: 


Commands Used:


Lessons Learned:


```

**Real-World Skills**: Cost optimization, resource management, FinOps

---

## 🔄 DAILY OPERATIONAL TASKS (Level 3)

### ✅ Progress: 0/4 Complete

---

### [ ] Task 23: Weekly Health Check
**Frequency**: Weekly  
**Time**: 30 minutes  
**Status**: Not Started  
**Last Completed**: ___  
**Attempts**: 0

**Checklist**:
1. [ ] Review all Grafana dashboards
2. [ ] Check for pending Kubernetes events
3. [ ] Verify all Prometheus targets UP
4. [ ] Review Trivy scan results
5. [ ] Check backup success rate
6. [ ] Review alert history
7. [ ] Check certificate expiration dates
8. [ ] Verify GitOps sync status
9. [ ] Review resource utilization trends
10. [ ] Document any anomalies

**Success Criteria**: Platform health report generated

**Solution Notes**:
```
Findings:


Actions Taken:


Follow-ups Required:


```

**Real-World Skills**: Proactive monitoring, operational excellence

---

### [ ] Task 24: Security Audit
**Frequency**: Monthly  
**Time**: 2 hours  
**Status**: Not Started  
**Last Completed**: ___  
**Attempts**: 0

**Checklist**:
1. [ ] Review Falco alerts from past month
2. [ ] Analyze Trivy vulnerability trends
3. [ ] Test network policy enforcement
4. [ ] Verify RBAC configurations
5. [ ] Check for exposed secrets
6. [ ] Review pod security standards compliance
7. [ ] Audit service account permissions
8. [ ] Test backup restoration
9. [ ] Review access logs
10. [ ] Update security documentation

**Success Criteria**: Security posture documented and improved

**Solution Notes**:
```
Findings:


Actions Taken:


Follow-ups Required:


```

**Real-World Skills**: Security operations, compliance, risk management

---

### [ ] Task 25: Capacity Planning
**Frequency**: Monthly  
**Time**: 1 hour  
**Status**: Not Started  
**Last Completed**: ___  
**Attempts**: 0

**Checklist**:
1. [ ] Analyze resource usage trends (30 days)
2. [ ] Project growth for next quarter
3. [ ] Check node pool utilization
4. [ ] Review storage growth
5. [ ] Estimate scaling requirements
6. [ ] Calculate cost projections
7. [ ] Plan infrastructure upgrades
8. [ ] Document capacity recommendations

**Success Criteria**: Capacity plan for next 3 months

**Solution Notes**:
```
Current Utilization:


Growth Projections:


Recommendations:


```

**Real-World Skills**: Capacity planning, forecasting, infrastructure management

---

### [ ] Task 26: Runbook Creation
**Frequency**: As needed  
**Time**: 1 hour per runbook  
**Status**: Not Started  
**Runbooks Created**: 0/8  
**Attempts**: 0

**Create runbooks for**:
1. [ ] Service restart procedure
2. [ ] Database backup/restore
3. [ ] Certificate rotation
4. [ ] Node maintenance
5. [ ] Scaling operations
6. [ ] Incident response
7. [ ] Deployment rollback
8. [ ] Security incident response

**Success Criteria**: Runbooks enable any team member to handle incidents

**Solution Notes**:
```
Runbooks Completed:


Templates Used:


Feedback Received:


```

**Real-World Skills**: Documentation, knowledge sharing, operational maturity

---

## 🎯 ADVANCED SCENARIOS (Level 3)

### ✅ Progress: 0/4 Complete

---

### [ ] Scenario 27: Multi-Region Failover
**Severity**: P0 (Critical)  
**Time Limit**: 30 minutes  
**Status**: Not Started  
**Actual Time**: ___ minutes  
**Attempts**: 0

**Situation**:
- Southeast Asia region has outage
- Need to failover to secondary region
- No secondary region exists yet

**Your Tasks**:
1. [ ] Design multi-region architecture
2. [ ] Plan data replication strategy
3. [ ] Configure DNS failover
4. [ ] Test failover procedure
5. [ ] Document RTO/RPO
6. [ ] Calculate costs

**Success Criteria**: Failover plan documented and tested

**Solution Notes**:
```
Architecture Design:


Implementation Steps:


Lessons Learned:


```

**Real-World Skills**: High availability, disaster recovery, architecture design

---

### [ ] Scenario 28: Zero-Downtime Migration
**Severity**: P1 (High)  
**Time Limit**: 4 hours  
**Status**: Not Started  
**Actual Time**: ___ minutes  
**Attempts**: 0

**Situation**:
- Need to migrate from Azure AKS to different cluster
- Cannot afford downtime
- Must maintain data consistency

**Your Tasks**:
1. [ ] Plan migration strategy (blue-green or canary)
2. [ ] Set up new cluster
3. [ ] Configure cross-cluster networking
4. [ ] Migrate stateless services first
5. [ ] Migrate stateful services with data sync
6. [ ] Switch traffic gradually
7. [ ] Verify functionality
8. [ ] Decommission old cluster

**Success Criteria**: Migration complete with zero downtime

**Solution Notes**:
```
Migration Strategy:


Challenges Faced:


Lessons Learned:


```

**Real-World Skills**: Migration planning, zero-downtime operations, risk management

---

### [ ] Scenario 29: Compliance Audit Preparation
**Severity**: P2 (Medium)  
**Time Limit**: 1 week  
**Status**: Not Started  
**Actual Time**: ___ days  
**Attempts**: 0

**Situation**:
- SOC 2 audit in 2 weeks
- Need to demonstrate security controls

**Your Tasks**:
1. [ ] Document all security policies
2. [ ] Collect audit logs (6 months)
3. [ ] Demonstrate encryption at rest/transit
4. [ ] Show access control mechanisms
5. [ ] Prove backup/recovery capabilities
6. [ ] Document incident response procedures
7. [ ] Show vulnerability management process
8. [ ] Prepare compliance evidence

**Success Criteria**: Pass audit with zero findings

**Solution Notes**:
```
Documentation Prepared:


Evidence Collected:


Gaps Identified:


```

**Real-World Skills**: Compliance, governance, audit preparation

---

### [ ] Scenario 30: Platform Upgrade
**Severity**: P1 (High)  
**Time Limit**: 4 hours  
**Status**: Not Started  
**Actual Time**: ___ minutes  
**Attempts**: 0

**Situation**:
- Kubernetes 1.34 → 1.35 upgrade required
- Istio 1.28 → 1.29 upgrade needed
- Must maintain service availability

**Your Tasks**:
1. [ ] Review upgrade compatibility
2. [ ] Test in staging environment
3. [ ] Plan upgrade sequence
4. [ ] Backup all configurations
5. [ ] Upgrade control plane
6. [ ] Upgrade worker nodes
7. [ ] Upgrade Istio
8. [ ] Verify all services healthy
9. [ ] Rollback plan ready

**Success Criteria**: Successful upgrade with <5 min downtime

**Solution Notes**:
```
Upgrade Plan:


Issues Encountered:


Lessons Learned:


```

**Real-World Skills**: Upgrade management, risk mitigation, platform maintenance

---

## 📊 PROGRESS TRACKING

### Skill Levels

**Level 1: Beginner** (Scenarios 1-10)
- Basic troubleshooting
- Following runbooks
- Using monitoring tools

**Level 2: Intermediate** (Scenarios 11-20)
- Independent problem-solving
- Creating runbooks
- Performance optimization

**Level 3: Advanced** (Scenarios 21-30)
- Architecture decisions
- Complex migrations
- Proactive optimization

### Completion Tracker

#### 🚨 Incident Response (Level 1)
- [ ] Scenario 1: Production Down - Frontend Unreachable
- [ ] Scenario 2: Memory Leak Detection
- [ ] Scenario 3: Certificate Expiration Alert
- [ ] Scenario 4: Disk Space Crisis
- [ ] Scenario 5: Cascading Failure

#### 🔒 Security Operations (Level 1)
- [ ] Scenario 6: Suspicious Runtime Activity
- [ ] Scenario 7: Vulnerability Remediation
- [ ] Scenario 8: Network Policy Breach

#### 📊 Observability (Level 2)
- [ ] Scenario 9: Missing Metrics
- [ ] Scenario 10: Alert Fatigue
- [ ] Scenario 11: Trace Investigation

#### ⚙️ Platform Engineering (Level 2)
- [ ] Scenario 12: GitOps Sync Failure
- [ ] Scenario 13: Autoscaling Not Working
- [ ] Scenario 14: Backup Restoration Test
- [ ] Scenario 15: Multi-Service Deployment

#### 🔧 Troubleshooting (Level 2)
- [ ] Scenario 16: DNS Resolution Failure
- [ ] Scenario 17: Image Pull Errors
- [ ] Scenario 18: Persistent Volume Issues

#### 🎭 Chaos Engineering (Level 2)
- [ ] Scenario 19: Pod Failure Simulation
- [ ] Scenario 20: Network Latency Injection

#### 📈 Performance & Cost (Level 3)
- [ ] Scenario 21: High Latency Investigation
- [ ] Scenario 22: Cost Optimization

#### 🔄 Daily Operations (Level 3)
- [ ] Task 23: Weekly Health Check
- [ ] Task 24: Security Audit
- [ ] Task 25: Capacity Planning
- [ ] Task 26: Runbook Creation

#### 🎯 Advanced Scenarios (Level 3)
- [ ] Scenario 27: Multi-Region Failover
- [ ] Scenario 28: Zero-Downtime Migration
- [ ] Scenario 29: Compliance Audit Preparation
- [ ] Scenario 30: Platform Upgrade

---

## 🎓 Learning Approach

### For Each Scenario:

1. **Read the situation** - Understand the problem
2. **Set a timer** - Practice under pressure
3. **Try solving independently** - No AI help initially
4. **Document your approach** - Write down commands and reasoning in Solution Notes
5. **Mark checkbox** - Update [ ] to [x] when complete
6. **Record actual time** - Compare against time limit
7. **Update progress tracker** - Update stats at top of document
8. **Create a runbook** - Document for future reference

### Mastery Indicators:

- ✅ **Beginner**: Can solve with guidance (mark checkbox, note "needed help")
- ✅ **Intermediate**: Can solve independently (mark checkbox, note "solved alone")
- ✅ **Advanced**: Can solve quickly under time limit (mark checkbox, note time)
- ✅ **Expert**: Can solve and teach others (mark checkbox, create runbook)

### Progress Updates:

After completing each scenario:
1. Mark the checkbox [x]
2. Fill in "Actual Time" field
3. Complete "Solution Notes" section
4. Update "Progress Tracker" at top
5. Update "Current Level" if you've completed a level tier

---

## 🚀 Getting Started

**Your First Task**: Scenario 1 - Production Down

1. Read the scenario carefully
2. Set a 15-minute timer
3. Try to solve it using kubectl, Prometheus, Grafana, etc.
4. Document every command you run
5. When solved (or time's up), fill in Solution Notes
6. Mark checkbox [x] and update progress tracker
7. Move to Scenario 2

**Remember**: Real engineers don't know everything - they know how to find answers quickly and systematically. These scenarios build that muscle memory.

---

**Ready to become a production-ready engineer?** Start with Scenario 1! 🔥
