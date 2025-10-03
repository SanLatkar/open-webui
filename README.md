# 🚀 Open WebUI Deployment on AWS EKS

A production-ready deployment of Open WebUI on Amazon EKS using Terraform, featuring automated infrastructure provisioning, SSL/TLS certificates, and custom domain configuration.

## 📋 Table of Contents

- [Overview](https://github.com/SanLatkar/open-webui/tree/1-deploy-open-webui-in-a-cloud-environment?tab=readme-ov-file#-overview)
- [Prerequisites](https://github.com/SanLatkar/open-webui/tree/1-deploy-open-webui-in-a-cloud-environment?tab=readme-ov-file#-prerequisites)
- [Quick Start](https://github.com/SanLatkar/open-webui/tree/1-deploy-open-webui-in-a-cloud-environment?tab=readme-ov-file#-quick-start)
- [Deployment Steps](https://github.com/SanLatkar/open-webui/tree/1-deploy-open-webui-in-a-cloud-environment?tab=readme-ov-file#-deployment-steps)
- [Configuration](https://github.com/SanLatkar/open-webui/tree/1-deploy-open-webui-in-a-cloud-environment?tab=readme-ov-file#%EF%B8%8F-configuration)
- [Problems Solved](https://github.com/SanLatkar/open-webui/tree/1-deploy-open-webui-in-a-cloud-environment?tab=readme-ov-file#%EF%B8%8F-problems-solved)
- [Cleanup](https://github.com/SanLatkar/open-webui/tree/1-deploy-open-webui-in-a-cloud-environment?tab=readme-ov-file#-cleanup)
- [Troubleshooting](https://github.com/SanLatkar/open-webui/tree/1-deploy-open-webui-in-a-cloud-environment?tab=readme-ov-file#-troubleshooting)

## 🎯 Overview

This project deploys Open WebUI (a user-friendly AI interface) on AWS EKS with:

- ✅ **Automated Infrastructure**: Terraform-managed EKS cluster, VPC, and networking
- ✅ **SSL/TLS Security**: AWS Certificate Manager for HTTPS
- ✅ **Custom Domain**: Route53 integration with custom domain
- ✅ **Scalable Architecture**: Kubernetes-based deployment on EKS
- ✅ **Cost-Optimized**: Free-tier friendly configuration

**Access URL**: `https://open-webui.sanketlatkar.cloud`

## 📦 Prerequisites

### Required Tools

1. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) (v2.x or higher)

2. [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) (v1.5.0 or higher)

3. [kubectl](https://kubernetes.io/docs/tasks/tools/) (optional, for cluster management)

### AWS Requirements

- **AWS Account** with appropriate permissions
- **IAM User** with the following permissions:
  - EKS Full Access
  - EC2 Full Access
  - VPC Full Access
  - Route53 Full Access
  - ACM Full Access
  - S3 Access (for Terraform state)
  - DynamoDB Access (for state locking)

### Domain Requirements

- **Registered Domain**: Purchase from any registrar (e.g., Namecheap, GoDaddy)
- **DNS Access**: Ability to update nameservers

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/SanLatkar/open-webui.git
cd open-webui
git checkout 1-deploy-open-webui-in-a-cloud-environment

# Run the automated setup script
chmod +x setup.sh deploy.sh
./setup.sh
```

## 📖 Deployment Steps

### Step 1: Configure AWS Credentials

```bash
aws configure
```

Enter your AWS credentials:
- **AWS Access Key ID**: Your access key
- **AWS Secret Access Key**: Your secret key
- **Default region**: `us-east-1` (or your preferred region)
- **Default output format**: `json`

` Note: Domain name and S3 bucket should be unique. You can purchase domain name and create S3 bucket of your choice. Don't forgot to update s3 bucket name in terraform backend and domain name in .tfvars `

### Step 2: Purchase Domain (Optional)

If you don't have a domain:
1. Purchase from [Namecheap](https://www.namecheap.com) or another registrar
2. Note down your domain name (e.g., `sanketlatkar.cloud`)

### Step 3: Create Route53 Hosted Zone

```bash
aws route53 create-hosted-zone \
  --name sanketlatkar.cloud \
  --caller-reference "open-webui-$(date +%s)"
```

**Important**: Copy the 4 nameservers from the output and update them in your domain registrar's DNS settings.

Example nameservers:
```
ns-123.awsdns-12.com
ns-456.awsdns-45.net
ns-789.awsdns-78.org
ns-012.awsdns-01.co.uk
```

### Step 4: Create Terraform Backend

Create S3 bucket for Terraform state:
```bash
aws s3api create-bucket \
  --bucket open-webui-sanket-latkar \
  --region us-east-1
```

Create DynamoDB table for state locking:
```bash
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

### Step 5: Deploy Infrastructure

Run the deployment script:
```bash
./deploy.sh
```

This will:
1. Initialize Terraform
2. Validate the configuration
3. Plan the infrastructure changes
4. Apply the changes to create:
   - VPC and networking components
   - EKS cluster with node groups
   - ACM certificate for SSL/TLS
   - Load balancer and ingress
   - Open WebUI application

**Deployment time**: Approximately 15-20 minutes

### Step 6: Verify Deployment

Wait for DNS propagation (5-30 minutes) and access:
```
https://open-webui.sanketlatkar.cloud
```

## ⚙️ Configuration

### Terraform Variables

Edit `Infra/prod.tfvars` to customize your deployment:

```hcl
# Name prefix or Anme for all resources
Name = "open-webui"

# AWS Configuration
region = "us-east-1"

# EKS Configuration
ami_type = "AL2023_x86_64_STANDARD"
k8_version = "1.32"
instance_types = "m7i-flex.large"
disk_size = 50
capacity_type = "ON_DEMAND"
desired_nodegorup_size = 1

# Domain Configuration
domain_name = "sanketlatkar.cloud"


```

### Environment-Specific Configs

- **Development**: `Infra/dev.tfvars`
- **Production**: `Infra/prod.tfvars`

## 🛠️ Problems Solved

### 1. **Free Tier Storage Constraints**

**Problem**: AWS free tier doesn't include EBS persistent volumes, making PVC usage costly.

**Solution**: 
- Used ephemeral storage for development
- Configured Open WebUI to use in-memory session management
- For production, consider EFS or S3 backend for persistence

### 2. **Domain Purchase Limitation**

**Problem**: Couldn't purchase domain directly through AWS Route53 due to budget constraints.

**Solution**:
- Purchased domain from Namecheap (more affordable)
- Created Route53 hosted zone manually
- Updated nameservers in Namecheap to point to AWS Route53
- Added manual DNS configuration step in deployment

### 3. **ACM Certificate Validation**

**Problem**: ACM certificate validation requires DNS records, creating a chicken-and-egg situation.

**Solution**:
- Pre-created Route53 hosted zone
- Automated certificate validation record creation in Terraform
- Added wait conditions for certificate validation

### 4. **EKS Cluster Access**

**Problem**: Initial kubectl configuration required manual steps.

**Solution**:
- Added automated kubeconfig update in deployment script
- Included IAM role mapping for cluster access
- Documented manual fallback steps

## 🧹 Cleanup

### Automated Cleanup

```bash
cd Infra
terraform destroy -auto-approve -var-file="prod.tfvars"
```

### Manual Cleanup (if needed)

1. **Delete Hosted Zone Records**:
```bash
# List all records
HOSTED_ZONE_ID=$(aws route53 list-hosted-zones --query "HostedZones[?Name=='sanketlatkar.cloud.'].Id" --output text)

# Delete the hosted zone (after removing all records except NS and SOA)
aws route53 delete-hosted-zone --id $HOSTED_ZONE_ID
```

2. **Delete S3 Bucket**:
```bash
# Empty the bucket first
aws s3 rm s3://open-webui-sanket-latkar --recursive

# Delete the bucket
aws s3api delete-bucket --bucket open-webui-sanket-latkar --region us-east-1
```

3. **Delete DynamoDB Table**:
```bash
aws dynamodb delete-table --table-name terraform-state-lock --region us-east-1
```

## 🔍 Troubleshooting

### Issue: Certificate validation stuck

**Symptom**: ACM certificate stays in "Pending Validation" status

**Solution**:
```bash
# Check DNS records
aws route53 list-resource-record-sets --hosted-zone-id <YOUR_ZONE_ID>

# Verify nameservers are correctly set at your domain registrar
dig NS sanketlatkar.cloud
```

### Issue: Unable to access Open WebUI

**Symptom**: Domain doesn't resolve or shows 404

**Solutions**:
1. **Check DNS propagation**:
   ```bash
   dig open-webui.sanketlatkar.cloud
   nslookup open-webui.sanketlatkar.cloud
   ```

2. **Verify Load Balancer**:
   ```bash
   kubectl get ingress -n open-webui
   kubectl get svc -n open-webui
   ```

3. **Check pod status**:
   ```bash
   kubectl get pods -n open-webui
   kubectl logs -n open-webui <pod-name>
   ```

### Issue: Terraform state locked

**Symptom**: `Error: Error acquiring the state lock`

**Solution**:
```bash
# Force unlock (use with caution)
cd Infra
terraform force-unlock <LOCK_ID>
```

### Issue: EKS cluster not accessible

**Symptom**: `kubectl` commands fail with authentication error

**Solution**:
```bash
# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name open-webui-cluster

# Verify connection
kubectl get nodes
```

## 📚 Additional Resources

- [Open WebUI Documentation](https://docs.openwebui.com/)
- [AWS EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Route53 Documentation](https://docs.aws.amazon.com/route53/)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.


## 👤 Author

**Sanket Latkar**
- GitHub: [@SanLatkar](https://github.com/SanLatkar)
- Domain: [sanketlatkar.cloud](https://sanketlatkar.cloud)

## ⭐ Acknowledgments

- Open WebUI team for the amazing AI interface
- AWS for the cloud infrastructure
- Terraform for infrastructure as code capabilities

---

**Note**: This deployment is optimized for learning and development purposes. For production use, consider:
- Implementing proper backup strategies
- Adding monitoring and logging (CloudWatch, Prometheus)
- Setting up CI/CD pipelines
- Implementing security best practices (network policies, RBAC)
- Using managed databases for persistence