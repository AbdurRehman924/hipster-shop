# Microservices Architecture Guide

This document explains each microservice in the Online Boutique application, their technologies, dependencies, and communication patterns.

## Architecture Overview

```
┌─────────────┐    ┌──────────────┐    ┌─────────────────┐
│   Browser   │───▶│   Frontend   │───▶│  Load Balancer  │
└─────────────┘    └──────────────┘    └─────────────────┘
                           │
                           ▼
    ┌──────────────────────────────────────────────────────┐
    │                 Internal Services                     │
    │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐   │
    │  │    Cart     │  │  Product    │  │  Currency   │   │
    │  │  Service    │  │  Catalog    │  │  Service    │   │
    │  └─────────────┘  └─────────────┘  └─────────────┘   │
    │                                                      │
    │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐   │
    │  │  Checkout   │  │  Payment    │  │  Shipping   │   │
    │  │  Service    │  │  Service    │  │  Service    │   │
    │  └─────────────┘  └─────────────┘  └─────────────┘   │
    │                                                      │
    │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐   │
    │  │    Email    │  │Recommendation│  │     Ad      │   │
    │  │  Service    │  │   Service    │  │  Service    │   │
    │  └─────────────┘  └─────────────┘  └─────────────┘   │
    └──────────────────────────────────────────────────────┘
```

## Service Details

### 1. Frontend Service
- **Technology**: Go (Golang)
- **Port**: 8080
- **Purpose**: Web UI and API gateway
- **Dependencies**: ALL other services
- **Key Features**:
  - HTTP server serving web pages
  - Session management
  - Service orchestration
  - Template rendering
- **Environment Variables**:
  - `PRODUCT_CATALOG_SERVICE_ADDR=productcatalogservice:3550`
  - `CURRENCY_SERVICE_ADDR=currencyservice:7000`
  - `CART_SERVICE_ADDR=cartservice:7070`
  - `RECOMMENDATION_SERVICE_ADDR=recommendationservice:8080`
  - `SHIPPING_SERVICE_ADDR=shippingservice:50051`
  - `CHECKOUT_SERVICE_ADDR=checkoutservice:5050`
  - `AD_SERVICE_ADDR=adservice:9555`

### 2. Cart Service
- **Technology**: C# (.NET)
- **Port**: 7070
- **Purpose**: Shopping cart management
- **Dependencies**: None (in-memory storage)
- **Key Features**:
  - Add/remove items from cart
  - Get cart contents
  - Empty cart functionality
  - In-memory storage (non-persistent)
- **gRPC Methods**:
  - `AddItem()`
  - `GetCart()`
  - `EmptyCart()`

### 3. Product Catalog Service
- **Technology**: Go (Golang)
- **Port**: 3550
- **Purpose**: Product inventory management
- **Dependencies**: None (JSON file storage)
- **Key Features**:
  - Product listing
  - Product search
  - Individual product details
  - Static JSON data source
- **Data Source**: `products.json` (9 products)
- **gRPC Methods**:
  - `ListProducts()`
  - `GetProduct()`
  - `SearchProducts()`

### 4. Currency Service
- **Technology**: Node.js
- **Port**: 7000
- **Purpose**: Currency conversion
- **Dependencies**: European Central Bank API
- **Key Features**:
  - Real-time exchange rates
  - Multi-currency support
  - Highest QPS service
- **External API**: European Central Bank
- **gRPC Methods**:
  - `GetSupportedCurrencies()`
  - `Convert()`

### 5. Payment Service
- **Technology**: Node.js
- **Port**: 50051
- **Purpose**: Payment processing (mock)
- **Dependencies**: None
- **Key Features**:
  - Credit card validation
  - Transaction ID generation
  - Mock payment processing
- **gRPC Methods**:
  - `Charge()`

### 6. Shipping Service
- **Technology**: Go (Golang)
- **Port**: 50051
- **Purpose**: Shipping calculations
- **Dependencies**: None
- **Key Features**:
  - Shipping cost estimation
  - Tracking ID generation
  - Address validation
- **gRPC Methods**:
  - `GetQuote()`
  - `ShipOrder()`

### 7. Email Service
- **Technology**: Python
- **Port**: 8080 (internal), 5000 (service)
- **Purpose**: Order confirmation emails
- **Dependencies**: None (mock)
- **Key Features**:
  - Email template rendering
  - Order confirmation
  - Mock email sending
- **Templates**: Jinja2 templates
- **gRPC Methods**:
  - `SendOrderConfirmation()`

### 8. Checkout Service
- **Technology**: Go (Golang)
- **Port**: 5050
- **Purpose**: Order orchestration
- **Dependencies**: 
  - Product Catalog Service
  - Cart Service
  - Payment Service
  - Shipping Service
  - Email Service
  - Currency Service
- **Key Features**:
  - Order processing workflow
  - Service coordination
  - Transaction management
- **Environment Variables**:
  - `PRODUCT_CATALOG_SERVICE_ADDR=productcatalogservice:3550`
  - `SHIPPING_SERVICE_ADDR=shippingservice:50051`
  - `PAYMENT_SERVICE_ADDR=paymentservice:50051`
  - `EMAIL_SERVICE_ADDR=emailservice:5000`
  - `CURRENCY_SERVICE_ADDR=currencyservice:7000`
  - `CART_SERVICE_ADDR=cartservice:7070`
- **gRPC Methods**:
  - `PlaceOrder()`

### 9. Recommendation Service
- **Technology**: Python
- **Port**: 8080
- **Purpose**: Product recommendations
- **Dependencies**: Product Catalog Service
- **Key Features**:
  - ML-based recommendations
  - Cart-based suggestions
  - Product filtering
- **Environment Variables**:
  - `PRODUCT_CATALOG_SERVICE_ADDR=productcatalogservice:3550`
- **gRPC Methods**:
  - `ListRecommendations()`

### 10. Ad Service
- **Technology**: Java
- **Port**: 9555
- **Purpose**: Contextual advertisements
- **Dependencies**: None
- **Key Features**:
  - Context-based ads
  - Keyword matching
  - Ad content generation
- **gRPC Methods**:
  - `GetAds()`

### 11. Load Generator
- **Technology**: Python (Locust)
- **Port**: N/A (client only)
- **Purpose**: Traffic simulation
- **Dependencies**: Frontend Service
- **Key Features**:
  - Realistic user behavior simulation
  - Load testing
  - Performance metrics
- **Target**: Frontend service HTTP endpoints

## Communication Patterns

### gRPC Communication
All internal service communication uses **gRPC** with Protocol Buffers:
- **Synchronous** request-response
- **Type-safe** with protobuf schemas
- **High performance** binary protocol
- **Service discovery** via Kubernetes DNS

### HTTP Communication
- **Frontend ↔ Browser**: HTTP/HTTPS
- **Load Generator ↔ Frontend**: HTTP

### Service Discovery
Services communicate using Kubernetes DNS:
```
servicename:port
Example: productcatalogservice:3550
```

## Data Flow Examples

### 1. Product Browsing
```
Browser → Frontend → Product Catalog Service → Frontend → Browser
```

### 2. Add to Cart
```
Browser → Frontend → Cart Service → Frontend → Browser
```

### 3. Checkout Process
```
Browser → Frontend → Checkout Service → {
  Cart Service (get items)
  Product Catalog Service (get details)
  Currency Service (convert prices)
  Shipping Service (calculate shipping)
  Payment Service (process payment)
  Email Service (send confirmation)
} → Frontend → Browser
```

### 4. Product Recommendations
```
Frontend → Recommendation Service → Product Catalog Service → Recommendation Service → Frontend
```

## Technology Choices Explained

### Why Go?
- **Frontend, Product Catalog, Checkout, Shipping**: Fast, concurrent, good for web services
- **Static binary deployment**
- **Excellent gRPC support**

### Why C#?
- **Cart Service**: Mature ecosystem, good Redis integration, enterprise-ready

### Why Node.js?
- **Currency, Payment**: Fast I/O, good for API integrations, JSON handling

### Why Python?
- **Email, Recommendation**: Rich libraries, ML frameworks, template engines

### Why Java?
- **Ad Service**: Enterprise patterns, robust ecosystem, JVM performance

## Deployment Considerations

### Resource Requirements
- **CPU Intensive**: Currency Service (API calls), Recommendation Service (ML)
- **Memory Intensive**: Frontend (templates), Product Catalog (data)
- **I/O Intensive**: All services (gRPC communication)

### Scaling Patterns
- **Horizontal**: All services support multiple replicas
- **Stateless**: All services except Cart (in-memory state)
- **Load Balancing**: Kubernetes service discovery + load balancing

### Health Checks
All services implement gRPC health checks for Kubernetes liveness/readiness probes.

## Security Considerations

### Network Security
- **Internal communication**: gRPC within cluster
- **External access**: Only Frontend via LoadBalancer
- **No direct database access**: In-memory or file-based storage

### Data Security
- **No persistent sensitive data**: Payment info is mocked
- **Session management**: Frontend handles user sessions
- **Input validation**: Each service validates its inputs

## Monitoring & Observability

### Metrics
- **gRPC metrics**: Request/response times, error rates
- **Business metrics**: Orders, cart additions, product views
- **Infrastructure metrics**: CPU, memory, network

### Tracing
- **OpenTelemetry integration**: Distributed tracing across services
- **Request correlation**: Track requests across service boundaries

### Logging
- **Structured logging**: JSON format for log aggregation
- **Service identification**: Each service logs with service name
- **Request IDs**: Correlation across service calls
