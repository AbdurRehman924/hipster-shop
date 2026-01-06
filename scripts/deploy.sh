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

cd ../k8s

echo "Deploying with Helm..."
helm upgrade --install hipster-shop ./helm/hipster-shop \
  --create-namespace

echo "Deployment complete!"
echo "Getting frontend service IP..."
kubectl get svc frontend -n hipster-shop
