data "aws_availability_zones" "available" {
  state = "available"
}

data "http" "workstation-external-ip" {
  url = "http://ipv4.icanhazip.com"
}

data "tls_certificate" "TLS_certificate" {
  url = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}