# Resource: aws_iam_role
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role

resource "aws_iam_role" "eks_cluster" {
  # The name of the role
  name = "${var.EKSvar.Name}-cluster-role"

  # The policy that grants an entity permission to assume the role.
  # Used to access AWS resources that you might not normally have access to.
  # The role that Amazon EKS will use to create AWS resources for Kubernetes clusters
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

  tags = {
    Name = "${var.EKSvar.Name}-cluster-role"
  }
}

locals {
  eks_cluster_policies = toset([
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  ])
#   {
#     cluster_policy = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
#     vpc_controller = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
#   }
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  for_each = local.eks_cluster_policies

  policy_arn = each.value
  role       = aws_iam_role.eks_cluster.name
}

# Resource: aws_eks_cluster
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster

resource "aws_eks_cluster" "eks" {
  # Name of the cluster.
  name = var.EKSvar.Name

  # The Amazon Resource Name (ARN) of the IAM role that provides permissions for 
  # the Kubernetes control plane to make calls to AWS API operations on your behalf
  role_arn = aws_iam_role.eks_cluster.arn

  # Desired Kubernetes master version
  version = var.EKSvar.k8_version

  vpc_config {
    # Indicates whether or not the Amazon EKS private API server endpoint is enabled
    endpoint_private_access = true

    # Indicates whether or not the Amazon EKS public API server endpoint is enabled
    endpoint_public_access = true

    public_access_cidrs = [local.workstation-external-cidr]

    # Get all subnet IDs dynamically
    subnet_ids = concat(values(var.private_subnet_ids), values(var.public_subnet_ids))
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
#   depends_on = [
#     aws_iam_role_policy_attachment.amazon_eks_cluster_policy
#   ]
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster
  ]
  tags = {
    Name = var.EKSvar.Name
  }

}

data "tls_certificate" "TLS_certificate" {
  url = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks-OIDC" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.TLS_certificate.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

output "OpenidARN" {
  value       = aws_iam_openid_connect_provider.eks-OIDC.arn
  description = "Openid ARN."
  # Setting an output value as sensitive prevents Terraform from showing its value in plan and apply.
  sensitive = false
}

output "OpenidProvider" {
  value       = aws_eks_cluster.eks.identity[0].oidc[0].issuer
  description = "Openid Provider URL."
  # Setting an output value as sensitive prevents Terraform from showing its value in plan and apply.
  sensitive = false
}

output "ClusterName" {
  value       = aws_eks_cluster.eks.name
  description = "Name of EKS cluster"
  # Setting an output value as sensitive prevents Terraform from showing its value in plan and apply.
  sensitive = false
}