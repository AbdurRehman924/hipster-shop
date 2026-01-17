#!/bin/bash
set -e

echo "🔄 Converting Helm charts to GitOps manifests..."

# Create remaining service manifests
SERVICES=("productcatalogservice" "currencyservice" "paymentservice" "shippingservice" "emailservice" "checkoutservice" "recommendationservice")

for service in "${SERVICES[@]}"; do
    echo "Creating manifest for $service..."
    
    # Get service details from Helm values
    case $service in
        "productcatalogservice")
            PORT=3550
            ;;
        "currencyservice")
            PORT=7000
            ;;
        "paymentservice")
            PORT=50051
            ;;
        "shippingservice")
            PORT=50051
            ;;
        "emailservice")
            PORT=8080
            ;;
        "checkoutservice")
            PORT=5050
            ;;
        "recommendationservice")
            PORT=8080
            ;;
    esac
    
    cat > "gitops/base/hipster-shop/${service}.yaml" << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $service
  namespace: hipster-shop
  labels:
    app: $service
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $service
  template:
    metadata:
      labels:
        app: $service
    spec:
      containers:
      - name: server
        image: gcr.io/google-samples/microservices-demo/$service:v0.10.0
        ports:
        - containerPort: $PORT
        resources:
          requests:
            cpu: 50m
            memory: 64Mi
          limits:
            cpu: 200m
            memory: 256Mi
---
apiVersion: v1
kind: Service
metadata:
  name: $service
  namespace: hipster-shop
spec:
  type: ClusterIP
  selector:
    app: $service
  ports:
  - port: $PORT
    targetPort: $PORT
EOF
done

echo "✅ All service manifests created!"
