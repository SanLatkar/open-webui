#!/bin/bash
set -e

echo "=== Open WebUI on EKS - Setup Script ==="
echo ""

# Step 1: Configure AWS
echo "Step 1: Configuring AWS..."
aws configure

# Step 2: Create Route53 Hosted Zone
echo ""
echo "Step 2: Creating Route53 Hosted Zone..."
aws route53 create-hosted-zone \
  --name sanketlatkar.cloud \
  --caller-reference "open-webui-$(date +%s)"

echo ""
echo "IMPORTANT: Copy the nameservers from above and update them in your domain registrar (Namecheap)"
echo "Press Enter after updating nameservers..."
read

# Step 3: Create S3 Bucket for Terraform State
echo ""
echo "Step 3: Creating S3 bucket for Terraform state..."
aws s3api create-bucket \
  --bucket open-webui-sanket-latkar123456 \
  --region us-east-1

# Step 4: Create DynamoDB Table for State Locking
echo ""
echo "Step 4: Creating DynamoDB table for state locking..."
aws dynamodb create-table \
  --table-name terraform-state-lock12345 \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1

echo ""
echo "✓ Setup complete!"
echo ""
echo "Do you want to run deploy.sh now? (y/n)"
read -r response

if [[ "$response" =~ ^[Yy]$ ]]; then
    echo ""
    echo "Starting deployment..."
    ./deploy.sh
else
    echo ""
    echo "Deployment skipped. Run ./deploy.sh when you're ready to deploy."
fi