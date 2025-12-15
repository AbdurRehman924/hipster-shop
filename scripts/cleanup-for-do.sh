#!/bin/bash

# Cleanup script to remove Google Cloud specific components
# Run this to prepare the project for DigitalOcean deployment

echo "🧹 Cleaning up Google Cloud specific components..."

# Remove Google Cloud specific folders
rm -rf .github/
rm -rf terraform/
rm -rf istio-manifests/
rm -rf kubernetes-manifests/
rm -rf release/
rm -rf .deploystack/

# Remove Google Cloud specific files
rm -f cloudbuild.yaml
rm -f skaffold.yaml

echo "✅ Cleanup complete!"
echo ""
echo "🤔 Choose your deployment method:"
echo "1. Minimal (Plain Kubernetes YAML) - Remove helm-chart/ and kustomize/"
echo "2. Helm (Recommended) - Remove kustomize/, keep helm-chart/"
echo "3. Kustomize - Remove helm-chart/, keep kustomize/base/"
echo ""
read -p "Enter choice (1/2/3): " choice

case $choice in
    1)
        rm -rf helm-chart/
        rm -rf kustomize/
        echo "📁 Minimal setup: /src/, /protos/, /scripts/"
        ;;
    2)
        rm -rf kustomize/
        echo "📁 Helm setup: /src/, /protos/, /helm-chart/, /scripts/"
        ;;
    3)
        rm -rf helm-chart/
        rm -rf kustomize/components/
        echo "📁 Kustomize setup: /src/, /protos/, /kustomize/base/, /scripts/"
        ;;
    *)
        echo "Invalid choice. Keeping both helm-chart/ and kustomize/"
        ;;
esac
