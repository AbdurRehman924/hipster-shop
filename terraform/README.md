# DigitalOcean Deployment

This Terraform configuration deploys the Online Boutique microservices application on DigitalOcean Kubernetes (DOKS).

## Prerequisites

1. [Terraform](https://www.terraform.io/downloads.html) installed
2. [DigitalOcean CLI](https://docs.digitalocean.com/reference/doctl/) (optional)
3. DigitalOcean API token

## Setup

1. Copy the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` and add your DigitalOcean API token:
   ```hcl
   do_token = "your_digitalocean_api_token_here"
   ```

## Deploy

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Plan the deployment:
   ```bash
   terraform plan
   ```

3. Apply the configuration:
   ```bash
   terraform apply
   ```

## Access the Application

After deployment, get the frontend LoadBalancer IP:
```bash
terraform output frontend_ip
```

Visit `http://<frontend_ip>` in your browser.

## Configure kubectl

To manage the cluster with kubectl:
```bash
doctl kubernetes cluster kubeconfig save hipster-shop
```

## Resources Created

- DOKS cluster (3 nodes, s-2vcpu-4gb)
- Container Registry
- Redis database cluster
- All microservices deployed as Kubernetes deployments
- LoadBalancer service for frontend

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

## Cost Estimation

- DOKS cluster: ~$72/month (3 x s-2vcpu-4gb nodes)
- Redis database: ~$15/month (db-s-1vcpu-1gb)
- LoadBalancer: ~$12/month
- Container Registry: ~$5/month (basic tier)

**Total: ~$104/month**
