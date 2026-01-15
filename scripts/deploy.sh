#!/bin/bash

# Deploy infrastructure first
echo "🚀 Deploying DigitalOcean infrastructure..."
cd terraform-infra
terraform init
terraform plan
terraform apply -auto-approve

# Get cluster credentials
echo "🔑 Getting cluster credentials..."
CLUSTER_ID=$(terraform output -raw cluster_id)
doctl kubernetes cluster kubeconfig save $CLUSTER_ID

cd ..

echo "📦 Deploying with Helm..."
helm upgrade --install hipster-shop k8s/helm/hipster-shop \
  --create-namespace --wait

# Deploy monitoring
echo "📊 Deploying monitoring stack..."
./scripts/deploy-monitoring.sh

# Deploy autoscaling
echo "🔄 Deploying autoscaling..."
./scripts/deploy-autoscaling.sh

# Deploy logging
echo "📝 Deploying logging stack..."
./scripts/deploy-logging.sh

# Deploy load generator
echo "⚡ Deploying load generator..."
kubectl apply -f k8s/autoscaling/loadgenerator.yaml

echo "✅ Deployment complete!"
echo ""
echo "🌐 Access URLs:"
echo "Frontend: kubectl port-forward svc/frontend 8080:8080 -n hipster-shop"
echo "Grafana: kubectl port-forward svc/grafana 3000:80 -n monitoring"
echo ""
echo "📊 Monitor autoscaling:"
echo "kubectl get hpa -n hipster-shop -w"
