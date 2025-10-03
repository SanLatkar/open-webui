# Helm chart for Open-WebUI deployment
resource "helm_release" "open-webui" {
  name       = "open-webui"
  repository = "https://helm.openwebui.com/" 
  chart      = "open-webui"
  namespace  = "open-webui"
  version    = "8.9.0"
  create_namespace = true

  values = [
    templatefile("${path.module}/values/open-webui-values.yaml", {
      name = var.Appsvar.Name
      domain_name = var.Appsvar.domain_name
      acm_certificate_arn = var.Appsvar.acm_certificate_arn
    })
  ]

}




resource "aws_route53_record" "open_webui" {
  zone_id = data.aws_route53_zone.hostedZone.zone_id
  name    = "${var.Appsvar.Name}.${var.Appsvar.domain_name}"
  type    = "A"

  alias {
    name                   = try(data.aws_lb.open_webui.dns_name, "")
    zone_id                = try(data.aws_lb.open_webui.zone_id, "")
    evaluate_target_health = false
  }

  depends_on = [data.aws_lb.open_webui]
  
}