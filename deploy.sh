#!/bin/bash
set -e

Infra_dir="Infra"
Helm_dir="Helm"

# Initialize Terraform in the Infra directory
terraform -chdir="$Infra_dir" init

# Validate the Terraform configuration
terraform -chdir="$Infra_dir" validate

# Plan the Terraform configuration
terraform -chdir="$Infra_dir" plan

# Apply the Terraform configuration
terraform -chdir="$Infra_dir" apply -auto-approve

# Install AWS ALB Controller using Helm
helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --values $Helm_dir/aws-alb-values.yaml 

# Deploy Open Web UI using Helm
helm repo add open-webui https://helm.openwebui.com/
helm repo update
helm upgrade -i open-webui open-webui/open-webui -n open-webui --create-namespace -f $Helm_dir/openwebui-values.yaml


# Add CNAME record in Namecheap
# Host="open-webui"
# VAlue="alb-dns-name" # Replace with the actual ALB DNS name
# TTL="1800

# Open WebUI will be accessible on https://open-webui.sanketlatkar.cloud


# Note:
# 1. Already purcahsed sanketlatkar.cloud domain from namecheap
# 2. ALB DNS name can be found in AWS console -> EC2 -> Load Balancers
# 3. Add CNAME record in Namecheap DNS settings for the domain
#    - Host: open-webui
#    - Value: <ALB DNS name>
#    - TTL: 1800
# 4. Cetificate for ingress is created in us-east-1 region in AWS Certificate Manager
# 5. Run 'terraform destroy' in Infra directory to destroy all resources created