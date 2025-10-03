# EKS OpenID Provider ARN
output "openid_provider_arn" {
  value       = aws_iam_openid_connect_provider.eks-OIDC.arn
  description = "Openid ARN."
  # Setting an output value as sensitive prevents Terraform from showing its value in plan and apply.
  sensitive = false
}

# EKS OpenID Provider URL
output "openid_provider_url" {
  value       = aws_eks_cluster.eks.identity[0].oidc[0].issuer
  description = "Openid Provider URL."
  # Setting an output value as sensitive prevents Terraform from showing its value in plan and apply.
  sensitive = false
}

# EKS Cluster Name
output "cluster_name" {
  value       = aws_eks_cluster.eks.name
  description = "Name of EKS cluster"
  # Setting an output value as sensitive prevents Terraform from showing its value in plan and apply.
  sensitive = false
}

# EKS Cluster endpoint
output "cluster_endpoint" {
  value       = aws_eks_cluster.eks.endpoint
  description = "EKS Cluster endpoint"
}

# EKS Cluster certificate authority data
output "cluster_certificate_authority_data" {
  value       = aws_eks_cluster.eks.certificate_authority[0].data
  description = "EKS Cluster certificate authority data"
  sensitive   = true
}