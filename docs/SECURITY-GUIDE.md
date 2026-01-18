# Security Scanning & Compliance Guide

Comprehensive security monitoring with vulnerability scanning, runtime protection, and policy enforcement.

## 🎯 What You'll Learn

- **Vulnerability Scanning**: Container image CVE detection with Trivy
- **Runtime Security**: Behavioral monitoring with Falco
- **Policy Enforcement**: Advanced constraints with OPA Gatekeeper
- **Security Monitoring**: Centralized security dashboards
- **Compliance**: Automated security best practices

## 🚀 Quick Start

```bash
# Deploy complete security stack
./scripts/deploy-security.sh

# Test security features
./scripts/test-security.sh
```

## 🔍 Trivy Vulnerability Scanning

### Features
- **Container Scanning**: Detect CVEs in container images
- **Configuration Scanning**: Find misconfigurations
- **Automated Reports**: Daily vulnerability assessments
- **Severity Filtering**: Focus on CRITICAL/HIGH/MEDIUM issues

### Usage
```bash
# View vulnerability reports
kubectl get vulnerabilityreports -A

# Detailed vulnerability info
kubectl describe vulnerabilityreport <report-name> -n hipster-shop

# Trigger manual scan
kubectl annotate deployment frontend trivy.scan/trigger=$(date +%s) -n hipster-shop
```

### Sample Output
```yaml
# Critical vulnerabilities found in frontend image
spec:
  vulnerabilities:
  - vulnerabilityID: CVE-2023-1234
    severity: CRITICAL
    title: "Buffer overflow in library"
    installedVersion: "1.2.3"
    fixedVersion: "1.2.4"
```

## 🦅 Falco Runtime Security

### Detection Rules
- **Shell Access**: Detect shell execution in containers
- **File Access**: Monitor sensitive file access
- **Network Activity**: Suspicious network connections
- **Privilege Escalation**: Detect privilege escalation attempts

### Custom Rules
```yaml
# Example: Detect cryptocurrency mining
- rule: Crypto Mining Activity
  condition: >
    spawned_process and
    proc.name in (xmrig, cpuminer, cgminer)
  output: Cryptocurrency mining detected (command=%proc.cmdline)
  priority: CRITICAL
```

### Monitoring
```bash
# View Falco events
kubectl logs -n falco -l app.kubernetes.io/name=falco -f

# Filter by priority
kubectl logs -n falco -l app.kubernetes.io/name=falco | grep CRITICAL
```

## 🚪 OPA Gatekeeper Policies

### Implemented Constraints

#### 1. Security Context Requirements
```yaml
# Enforce non-root containers
- runAsNonRoot: true
- allowPrivilegeEscalation: false
```

#### 2. Image Registry Restrictions
```yaml
# Only allow trusted registries
repos:
  - "gcr.io/google-samples/"
  - "registry.k8s.io/"
  - "docker.io/library/"
```

#### 3. Resource Policies
```yaml
# Block LoadBalancer services (use Ingress)
# Require specific labels on deployments
```

### Testing Policies
```bash
# This will be blocked
kubectl run test --image=nginx --privileged -n hipster-shop

# This will be allowed
kubectl run test --image=gcr.io/google-samples/hello-app:1.0 -n hipster-shop
```

## 📊 Security Monitoring

### Grafana Dashboard
- **Vulnerability Trends**: Track CVE counts over time
- **Security Events**: Falco alert frequency
- **Policy Violations**: Gatekeeper constraint violations
- **Compliance Score**: Overall security posture

### Key Metrics
```promql
# Critical vulnerabilities
sum by (namespace) (trivy_vulnerability_count{severity="CRITICAL"})

# Security events rate
rate(falco_events_total[5m])

# Policy violations
gatekeeper_violations_total
```

## 🧪 Security Testing

### Vulnerability Testing
```bash
# Deploy intentionally vulnerable image
kubectl run vuln-test --image=vulnerables/web-dvwa -n hipster-shop

# Check for detected vulnerabilities
kubectl get vulnerabilityreports -n hipster-shop
```

### Runtime Security Testing
```bash
# Trigger shell detection
kubectl exec -it deployment/frontend -n hipster-shop -- /bin/bash

# Trigger file access detection
kubectl exec -it deployment/frontend -n hipster-shop -- cat /etc/passwd
```

### Policy Testing
```bash
# Test security context policy
kubectl run test-privileged --image=nginx --privileged -n hipster-shop
# Should be blocked

# Test image registry policy
kubectl run test-bad-image --image=malicious/image -n hipster-shop
# Should be blocked
```

## 🔧 Advanced Configuration

### Custom Trivy Policies
```yaml
# Scan specific namespaces
OPERATOR_TARGET_NAMESPACES: "hipster-shop,monitoring"

# Severity threshold
TRIVY_SEVERITY: "CRITICAL,HIGH"
```

### Falco Tuning
```yaml
# Reduce noise
syscall_event_drops:
  rate: 0.03333
  max_burst: 1000

# Custom outputs
httpOutput:
  enabled: true
  url: "http://webhook-endpoint"
```

### Gatekeeper Exemptions
```yaml
# Exempt system namespaces
spec:
  match:
    excludedNamespaces: ["kube-system", "gatekeeper-system"]
```

## 🎓 Security Best Practices

### 1. Image Security
- Use minimal base images (distroless, alpine)
- Regularly update base images
- Scan images in CI/CD pipeline
- Use image signing and verification

### 2. Runtime Security
- Run containers as non-root
- Use read-only root filesystems
- Implement resource limits
- Monitor file system changes

### 3. Network Security
- Implement network policies
- Use service mesh for mTLS
- Monitor network traffic
- Restrict egress connections

### 4. Policy Management
- Start with warn mode, then enforce
- Regular policy reviews
- Document policy exceptions
- Automate policy testing

## 🚨 Incident Response

### Security Alert Workflow
1. **Detection**: Falco/Trivy alerts
2. **Assessment**: Check severity and impact
3. **Containment**: Isolate affected pods
4. **Investigation**: Analyze logs and events
5. **Remediation**: Apply fixes and updates
6. **Recovery**: Restore normal operations

### Emergency Commands
```bash
# Isolate compromised pod
kubectl label pod <pod-name> security.breach=true -n hipster-shop
kubectl apply -f emergency-network-policy.yaml

# Scale down compromised deployment
kubectl scale deployment <deployment> --replicas=0 -n hipster-shop

# Collect forensic data
kubectl logs <pod-name> -n hipster-shop > incident-logs.txt
```

## 📈 Compliance Reporting

### Generate Reports
```bash
# Vulnerability summary
kubectl get vulnerabilityreports -A -o json | jq '.items[].report.summary'

# Policy compliance
kubectl get constraints -o json | jq '.items[].status'

# Security events summary
kubectl logs -n falco -l app.kubernetes.io/name=falco --since=24h | grep -c "CRITICAL\|WARNING"
```

## 🎯 Next Steps

1. **Integrate with CI/CD**: Add security scanning to pipelines
2. **Automate Response**: Create automated incident response
3. **Extend Monitoring**: Add custom security metrics
4. **Regular Audits**: Schedule security assessments
5. **Team Training**: Security awareness and response training

This security implementation provides **enterprise-grade protection** for your Kubernetes platform!
