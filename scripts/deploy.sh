#!/bin/bash

# Deploy infrastructure first
echo "Deploying DigitalOcean infrastructure..."
cd terraform-infra
terraform init
terraform plan
terraform apply -auto-approve

# Get cluster credentials
echo "Getting cluster credentials..."
CLUSTER_ID=$(terraform output -raw cluster_id)
doctl kubernetes cluster kubeconfig save $CLUSTER_ID

# Get Redis connection details
REDIS_HOST=$(terraform output -raw redis_host)
REDIS_PORT=$(terraform output -raw redis_port)
REDIS_PASSWORD=$(terraform output -raw redis_password)

cd ../k8s

echo "Choose deployment method:"
echo "1) Helm"
echo "2) Kustomize"
echo "3) Plain manifests"
read -p "Enter choice (1-3): " choice

case $choice in
  1)
    echo "Deploying with Helm..."
    helm upgrade --install hipster-shop ./helm/hipster-shop \
      --set redis.host=$REDIS_HOST \
      --set redis.port=$REDIS_PORT \
      --set redis.password=$REDIS_PASSWORD \
      --create-namespace
    ;;
  2)
    echo "Deploying with Kustomize..."
    kubectl apply -k kustomize/base
    ;;
  3)
    echo "Deploying with plain manifests..."
    kubectl apply -f manifests/namespace/
    kubectl apply -f manifests/deployments/
    kubectl apply -f manifests/services/
    ;;
  *)
    echo "Invalid choice"
    exit 1
    ;;
esac

echo "Deployment complete!"
echo "Getting frontend service IP..."
kubectl get svc frontend -n hipster-shop
