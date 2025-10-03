# IAM Role for EKS Cluster
resource "aws_iam_role" "eks_cluster" {
  # The name of the role
  name = "${var.EKSvar.Name}-cluster-role"

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
}

# EKS Cluster Role Policy Attachments
resource "aws_iam_role_policy_attachment" "eks_cluster" {
  for_each = local.eks_cluster_policies

  policy_arn = each.value
  role       = aws_iam_role.eks_cluster.name
}

# Override with variable or hardcoded value if necessary
locals {
  workstation-external-cidr = "${chomp(data.http.workstation-external-ip.response_body)}/32"
}

# EKS Cluster
resource "aws_eks_cluster" "eks" {
  # Name of the cluster.
  name = var.EKSvar.Name

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

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster
  ]
  tags = {
    Name = var.EKSvar.Name
  }

}

# IAM Role for EKS Node Group
resource "aws_iam_openid_connect_provider" "eks-OIDC" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.TLS_certificate.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks.identity[0].oidc[0].issuer

  tags = {
    Name = "${var.EKSvar.Name}-OIDC-provider"
  }
}