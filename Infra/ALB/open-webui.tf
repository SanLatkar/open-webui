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

  depends_on = [helm_release.open_webui]
}

output "open_webui_url" {
  value       = try(data.aws_lb.open_webui.dns_name, "") != "" ? "https://${var.name}.${var.domain_name}" : "Waiting for ALB to provision..."
  description = "Open-WebUI URL"
}