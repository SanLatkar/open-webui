#!/bin/bash
set -e

cd Infra

# Initialize Terraform in the Infra directory
terraform init

# Validate the Terraform configuration
terraform validate

# Plan the Terraform configuration
terraform plan -var-file="prod.tfvars"

# Apply the Terraform configuration
terraform apply -auto-approve -var-file="prod.tfvars"


# Open WebUI will be accessible on https://open-webui.sanketlatkar.cloud

# Note:
# 1. Already purcahsed sanketlatkar.cloud domain from namecheap
# 2. Created a hosted zone in AWS Route53 for sanketlatkar.cloud
