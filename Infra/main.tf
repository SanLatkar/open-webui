


terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.10.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.Name
}

# Helm Provider Configuration
provider "helm" {
  kubernetes = {
    host                   = module.EKS.cluster_endpoint
    cluster_ca_certificate = base64decode(module.EKS.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# Module to create AWS VPC
module "VPC" {
  source = "./VPC"
  VPCvar = local.VPCvar
}

# Module to create AWS EKS
module "EKS" {
  source = "./EKS"
  EKSvar = local.EKSvar
  private_subnet_ids = module.VPC.private_subnet_ids
  public_subnet_ids = module.VPC.public_subnet_ids

  depends_on = [
    module.VPC
  ]
}

# Module to create Addons
module "Addon" {
  source = "./Addon"
  Addonvar = local.Addonvar

  depends_on = [
    module.EKS
  ]
}

# Module to create Apps
module "Apps" {
  source = "./Apps"
  Appsvar = local.Appsvar

  depends_on = [
    module.Addon
  ]
}

# Module to create AWS ACM
module "ACM" {
  source = "./ACM"
  ACMvar = local.ACMvar
}


# Local values for VPC module
locals {
  VPCvar = {
    subnets = local.subnets
    public_subnets = local.public_subnets
    private_subnets = local.private_subnets
    Name = var.Name
  }
}

# Local values for Subnets of VPC module
locals {
  subnets = {
    "public-1" = {
      cidr_block = "192.168.0.0/18"
      az_index   = 0
      type       = "public"
    }
    "public-2" = {
      cidr_block = "192.168.64.0/18"
      az_index   = 1
      type       = "public"
    }
    "private-1" = {
      cidr_block = "192.168.128.0/18"
      az_index   = 0
      type       = "private"
    }
    "private-2" = {
      cidr_block = "192.168.192.0/18"
      az_index   = 1
      type       = "private"
    }
  }
  # Get public and private subnets
  public_subnets  = { for k, v in local.subnets : k => v if v.type == "public" }
  private_subnets = { for k, v in local.subnets : k => v if v.type == "private" }
}

# Local values for EKS module
locals {
  EKSvar = {
    ami_type = var.ami_type
    instance_types = var.instance_types
    k8_version = var.k8_version
    Name = var.Name
    desired_nodegorup_size = var.desired_nodegorup_size
    disk_size = var.disk_size
    capacity_type = var.capacity_type
    
  }
}

# Local values for Addon module
locals {
  Addonvar = {
    openid_provider_arn     = module.EKS.openid_provider_arn
    openid_provider_url = module.EKS.openid_provider_url
    Name = var.Name
    region = var.region
    domain_name = var.domain_name
    vpc_id = module.VPC.vpc_id
    acm_certificate_arn = module.ACM.acm_certificate_arn
  }
}

# Local values for Apps module
locals {
  Appsvar = {
    Name = var.Name
    domain_name = var.domain_name
    acm_certificate_arn = module.ACM.acm_certificate_arn
  }
}

# Local values for ACM module
locals {
  ACMvar = {
    Name = var.Name
    domain_name = var.domain_name
  }
}

# Open WebUI Status Output
output "open_webui_helm_release_status" {
  value       = module.Apps.open_webui_helm_release_status
  description = "OPen Webui Helm release status"
}

# Open WebUI URL Output
output "open_webui_url" {
  value       = module.Apps.open_webui_url
  description = "Open-WebUI URL"
}
