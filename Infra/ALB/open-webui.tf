resource "helm_release" "open-webui" {
  name       = "open-webui"
  repository = "https://helm.openwebui.com/" 
  chart      = "open-webui"
  namespace  = "open-webui"
  version    = "8.9.0"
  create_namespace = true

  values = [
    templatefile("${path.module}/open-webui-values.yaml", {
      name = var.ALBvar.Name
      domain_name = var.ALBvar.domain_name
      acm_certificate_arn = var.ALBvar.acm_certificate_arn
    })
  ]

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSLoadBalancerControllerRolePolicyAttachment
  ]
}


# Find the ALB created by the ingress controller using tags
data "aws_lb" "open_webui" {
  tags = {
    "ingress.k8s.aws/stack" = var.ALBvar.Name
  }

  depends_on = [helm_release.open-webui]
}

output "alb_dns_name" {
  value       = try(data.aws_lb.open_webui.dns_name, "Provisioning...")
  description = "DNS name of the ALB"
  
}

output "open_webui_url" {
  value       = try(data.aws_lb.open_webui.dns_name, "") != "" ? "https://${var.ALBvar.Name}.${var.ALBvar.domain_name}" : "Waiting for ALB to provision..."
  description = "Open-WebUI URL"
}
output "open_webui_helm_release_status" {
  value       = helm_release.open-webui.status
  description = "Status of the Helm release"
}


data "aws_route53_zone" "hostedZone" {
  name         = var.ALBvar.domain_name
  private_zone = false
}

resource "aws_route53_record" "open_webui" {
  zone_id = data.aws_route53_zone.hostedZone.zone_id
  name    = "${var.ALBvar.Name}.${var.ALBvar.domain_name}"
  type    = "A"

  alias {
    name                   = try(data.aws_lb.open_webui.dns_name, "")
    zone_id                = try(data.aws_lb.open_webui.zone_id, "")
    evaluate_target_health = false
  }

  depends_on = [data.aws_lb.open_webui]
  
}