# Hipster Shop Kubernetes Infrastructure

Terraform-based infrastructure deployment for Google's Online Boutique microservices demo on DigitalOcean Kubernetes (DOKS).

## Architecture

This project deploys a complete microservices e-commerce application with:
- 10 microservices (Go, C#, Node.js, Python, Java)
- DigitalOcean Kubernetes cluster
- Redis database
- Container registry
- Load balancer

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- DigitalOcean API token
- [kubectl](https://kubernetes.io/docs/tasks/tools/) (optional)

## Quick Start

1. **Configure variables:**
   ```bash
   cp terraform/terraform.tfvars.example terraform/terraform.tfvars
   # Edit terraform.tfvars with your DO token
   ```

2. **Deploy infrastructure:**
   ```bash
   cd terraform
   terraform init
   terraform plan
   terraform apply
   ```

3. **Access application:**
   ```bash
   terraform output frontend_ip
   # Visit http://<frontend_ip>
   ```

## Cost Estimation

- DOKS cluster: ~$72/month
- Redis database: ~$15/month  
- Load balancer: ~$12/month
- Container registry: ~$5/month

**Total: ~$104/month**

## Cleanup

```bash
terraform destroy
```

## Documentation

See [docs/flow/microservices-architecture.md](docs/flow/microservices-architecture.md) for detailed architecture information.
