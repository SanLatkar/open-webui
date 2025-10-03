# Find the ALB created by the ingress controller using tags
data "aws_lb" "open_webui" {
  tags = {
    "ingress.k8s.aws/stack" = var.Appsvar.Name
  }

  depends_on = [helm_release.open-webui]
}

# Get the Route 53 hosted zone
data "aws_route53_zone" "hostedZone" {
  name         = var.Appsvar.domain_name
  private_zone = false
}