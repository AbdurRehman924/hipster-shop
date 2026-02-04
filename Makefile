# Hipster Shop - Enhanced Learning Platform
# Automation for 15-phase cloud-native mastery journey

.PHONY: help init status clean learning-help

# Default target
help: ## Show available commands
	@echo "🚀 Hipster Shop - Cloud-Native Learning Platform"
	@echo "==============================================="
	@echo ""
	@echo "Learning Commands:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "📚 For detailed learning guidance, see: docs/LEARNING-PROGRESS.md"

learning-help: ## Show learning methodology and phase overview
	@echo "🎓 Enhanced Learning Methodology"
	@echo "==============================="
	@echo ""
	@echo "📊 15 Phases | 1000 Micro-tasks | Senior-level Mastery"
	@echo ""
	@echo "Phase 1:  Foundation & Infrastructure (Tasks 1-30)"
	@echo "Phase 2:  Observability & Monitoring (Tasks 31-75)"
	@echo "Phase 3:  Security & Compliance (Tasks 76-155)"
	@echo "Phase 4:  Service Mesh & Networking (Tasks 156-255)"
	@echo "Phase 5:  GitOps & Automation (Tasks 256-335)"
	@echo "Phase 6:  Centralized Logging (Tasks 336-380)"
	@echo "Phase 7:  Autoscaling & Performance (Tasks 381-460)"
	@echo "Phase 8:  Advanced Traffic Management (Tasks 461-560)"
	@echo "Phase 9:  Backup & Disaster Recovery (Tasks 561-640)"
	@echo "Phase 10: Chaos Engineering (Tasks 641-685)"
	@echo "Phase 11: Cost Optimization (Tasks 686-730)"
	@echo "Phase 12: Advanced Security (Tasks 731-830)"
	@echo "Phase 13: Multi-Environment Setup (Tasks 831-890)"
	@echo "Phase 14: Distributed Tracing (Tasks 891-935)"
	@echo "Phase 15: CI/CD Integration (Tasks 936-1000)"
	@echo ""
	@echo "🎯 Current Status: Ready for Phase 1"
	@echo "📖 Next: Follow docs/LEARNING-PROGRESS.md for step-by-step guidance"

# Infrastructure Management
init: ## Initialize infrastructure (Phase 1)
	@echo "🏗️  Initializing infrastructure for learning..."
	cd terraform-infra && terraform init
	@echo "✅ Ready to deploy cluster for Phase 1!"

deploy-cluster: ## Deploy Kubernetes cluster (Phase 1)
	@echo "🚀 Deploying DigitalOcean Kubernetes cluster..."
	cd terraform-infra && terraform apply
	@echo "✅ Cluster deployed! Get kubeconfig and begin Phase 2!"

# Learning Progress Tracking
status: ## Show current learning progress and platform status
	@echo "📊 Learning Progress Status"
	@echo "=========================="
	@echo "Current Phase: Check docs/LEARNING-PROGRESS.md"
	@echo ""
	@echo "🏗️  Infrastructure Status:"
	@if kubectl cluster-info >/dev/null 2>&1; then \
		echo "✅ Kubernetes cluster: Connected"; \
		kubectl get nodes 2>/dev/null || echo "❌ No nodes found"; \
	else \
		echo "❌ Kubernetes cluster: Not connected"; \
		echo "   Run 'make deploy-cluster' to start Phase 1"; \
	fi

# Quick Health Checks
health: ## Quick health check of deployed components
	@echo "🔍 Platform Health Check"
	@echo "======================="
	@kubectl get pods --all-namespaces 2>/dev/null || echo "❌ No cluster connection"

# Cleanup and Reset
clean-namespaces: ## Clean up learning namespaces (keep cluster)
	@echo "🧹 Cleaning up learning namespaces..."
	kubectl delete namespace monitoring istio-system argocd logging autoscaling --ignore-not-found=true
	@echo "✅ Namespaces cleaned! Ready for fresh learning iteration."

destroy-all: ## Complete teardown (nuclear option)
	@echo "💥 Destroying all infrastructure..."
	cd terraform-infra && terraform destroy -auto-approve
	@echo "✅ Complete reset! Ready for fresh start."

# Learning Utilities
next-phase: ## Show what to do next in learning journey
	@echo "🎯 Next Learning Steps"
	@echo "===================="
	@echo "1. Check docs/LEARNING-PROGRESS.md for current phase"
	@echo "2. Follow micro-task methodology"
	@echo "3. Execute commands hands-on for maximum learning"
	@echo "4. Verify each step before proceeding"
	@echo ""
	@echo "📚 Remember: Learning by doing is the key to mastery!"
