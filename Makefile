# Makefile for Hipster Shop Platform

.PHONY: help deploy destroy health-check lint validate clean

# Default target
help: ## Show this help message
	@echo "Hipster Shop Platform - Available Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Infrastructure
infra-init: ## Initialize Terraform
	cd terraform-infra && terraform init

infra-plan: ## Plan Terraform changes
	cd terraform-infra && terraform plan

infra-apply: ## Apply Terraform changes
	cd terraform-infra && terraform apply

infra-destroy: ## Destroy infrastructure
	cd terraform-infra && terraform destroy

# Application Deployment
deploy: ## Deploy complete platform
	./scripts/deploy.sh

deploy-app: ## Deploy only the application
	helm upgrade --install hipster-shop k8s/helm/hipster-shop --create-namespace --namespace hipster-shop

deploy-monitoring: ## Deploy monitoring stack
	./scripts/deploy-monitoring.sh

deploy-security: ## Deploy security components
	./scripts/deploy-security.sh

deploy-networking: ## Deploy networking components
	./scripts/deploy-networking.sh

deploy-istio: ## Deploy Istio service mesh
	./scripts/deploy-istio.sh

deploy-backup: ## Deploy backup solution
	./scripts/deploy-backup.sh

# Validation and Testing
validate: ## Validate all configurations
	@echo "Validating Terraform..."
	cd terraform-infra && terraform fmt -check -recursive
	cd terraform-infra && terraform validate
	@echo "Validating Kubernetes manifests..."
	find k8s/ -name "*.yaml" -exec kubectl --dry-run=client apply -f {} \;
	@echo "Linting Helm charts..."
	helm lint k8s/helm/hipster-shop/
	helm lint k8s/helm/monitoring/

health-check: ## Run comprehensive health check
	./scripts/health-check.sh

test-backup: ## Test backup functionality
	./scripts/test-backup.sh

test-security: ## Test security components
	./scripts/test-security.sh

test-network: ## Test network policies
	./scripts/test-network-policies.sh

# Development
lint: ## Lint all code and configurations
	@echo "Linting Terraform..."
	cd terraform-infra && terraform fmt -recursive
	@echo "Linting YAML files..."
	find . -name "*.yaml" -o -name "*.yml" | xargs yamllint -d relaxed

format: ## Format all code
	cd terraform-infra && terraform fmt -recursive

# Monitoring and Observability
port-forward-grafana: ## Port forward to Grafana
	kubectl port-forward svc/grafana 3000:80 -n monitoring

port-forward-prometheus: ## Port forward to Prometheus
	kubectl port-forward svc/prometheus 9090:9090 -n monitoring

port-forward-jaeger: ## Port forward to Jaeger (if Istio is deployed)
	kubectl port-forward svc/jaeger 16686:16686 -n istio-system

port-forward-kiali: ## Port forward to Kiali (if Istio is deployed)
	kubectl port-forward svc/kiali 20001:20001 -n istio-system

# Cleanup
clean-app: ## Remove application
	helm uninstall hipster-shop -n hipster-shop || true
	kubectl delete namespace hipster-shop || true

clean-monitoring: ## Remove monitoring stack
	helm uninstall prometheus -n monitoring || true
	helm uninstall grafana -n monitoring || true
	kubectl delete namespace monitoring || true

clean-all: ## Remove everything except infrastructure
	kubectl delete namespace hipster-shop monitoring istio-system falco trivy-system velero || true

# Logs and Debugging
logs-frontend: ## Show frontend logs
	kubectl logs -f deployment/frontend -n hipster-shop

logs-monitoring: ## Show monitoring logs
	kubectl logs -f deployment/prometheus -n monitoring

describe-pods: ## Describe all pods in hipster-shop namespace
	kubectl describe pods -n hipster-shop

get-events: ## Get recent events
	kubectl get events --sort-by=.metadata.creationTimestamp -A

# Quick Status
status: ## Show platform status
	@echo "=== Namespaces ==="
	kubectl get namespaces
	@echo ""
	@echo "=== Hipster Shop Pods ==="
	kubectl get pods -n hipster-shop
	@echo ""
	@echo "=== Services ==="
	kubectl get svc -n hipster-shop
	@echo ""
	@echo "=== Ingress ==="
	kubectl get ingress -A

# Load Testing
load-test: ## Run load test against the application
	kubectl run load-test --image=busybox --rm -i --restart=Never -- \
		wget -q -O- http://frontend.hipster-shop:8080

# Backup Operations
backup-now: ## Create immediate backup
	velero backup create manual-backup-$(shell date +%Y%m%d-%H%M%S) \
		--include-namespaces hipster-shop,monitoring

list-backups: ## List all backups
	velero backup get

# Cost Analysis
cost-report: ## Generate cost report (requires kubecost)
	kubectl port-forward svc/kubecost-cost-analyzer 9090:9090 -n kubecost &
	@echo "Kubecost available at http://localhost:9090"

cost-optimization: ## Run cost optimization analysis
	./scripts/cost-optimization.sh

# Advanced Testing
test-autoscaling: ## Test HPA and VPA functionality
	./scripts/test-autoscaling.sh

test-all: ## Run all tests
	make validate
	make health-check
	make test-security
	make test-network
	make test-autoscaling
