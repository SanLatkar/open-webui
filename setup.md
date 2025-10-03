```
1. Install Tools
   ├── AWS CLI
   ├── Terraform
   ├── kubectl
   └── Helm

2. Configure AWS
   └── aws configure (credentials + region)

3. Purchase Domain
   └── Buy sanketlatkar.cloud from Namecheap
   └── Create hosted zone

4. Create Terraform Backend
   ├── Create S3 bucket
   └── Create DynamoDB table

aws configure
aws s3api create-bucket --bucket open-webui-sanket-latkar --region us-east-1
aws dynamodb create-table --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST --region us-east-1

create hosted zone and paste ns records to namecheap custom dns
```