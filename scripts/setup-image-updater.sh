#!/bin/bash
set -e

echo "🔄 Setting up ArgoCD Image Updater..."

# Install ArgoCD Image Updater
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/stable/manifests/install.yaml

# Wait for deployment
kubectl wait --for=condition=available --timeout=300s deployment/argocd-image-updater -n argocd

echo "✅ ArgoCD Image Updater installed!"
echo ""
echo "📝 To enable image updates, add annotations to your Application:"
echo "argocd-image-updater.argoproj.io/image-list: frontend=gcr.io/google-samples/microservices-demo/frontend"
echo "argocd-image-updater.argoproj.io/write-back-method: git"
