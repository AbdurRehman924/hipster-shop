#!/bin/bash

# Multi-architecture Docker build script for Online Boutique
# Usage: ./scripts/build-multiarch.sh <your-registry>
# Example: ./scripts/build-multiarch.sh registry.digitalocean.com/myregistry

if [ -z "$1" ]; then

    echo "Usage: $0 <registry-url>"
    echo "Example: $0 registry.digitalocean.com/myregistry"
    exit 1
fi

REGISTRY=$1
VERSION=${2:-v1}

# Ensure buildx is available
docker buildx create --use --name multiarch-builder 2>/dev/null || docker buildx use multiarch-builder

echo "Building multi-architecture images for registry: $REGISTRY"

# Build each service
services=(
    "adservice:src/adservice"
    "cartservice:src/cartservice/src"
    "checkoutservice:src/checkoutservice"
    "currencyservice:src/currencyservice"
    "emailservice:src/emailservice"
    "frontend:src/frontend"
    "loadgenerator:src/loadgenerator"
    "paymentservice:src/paymentservice"
    "productcatalogservice:src/productcatalogservice"
    "recommendationservice:src/recommendationservice"
    "shippingservice:src/shippingservice"
    "shoppingassistantservice:src/shoppingassistantservice"
)

for service_info in "${services[@]}"; do
    IFS=':' read -r service_name service_path <<< "$service_info"
    
    echo "Building $service_name..."
    docker buildx build \
        --platform linux/amd64,linux/arm64 \
        -t $REGISTRY/$service_name:$VERSION \
        --push \
        $service_path
    
    if [ $? -eq 0 ]; then
        echo "✅ Successfully built $service_name"
    else
        echo "❌ Failed to build $service_name"
        exit 1
    fi
done

echo "🎉 All services built successfully!"
echo "Images pushed to: $REGISTRY"
