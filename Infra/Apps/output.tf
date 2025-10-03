# output "alb_dns_name" {
#   value       = try(data.aws_lb.open_webui.dns_name, "Provisioning...")
#   description = "DNS name of the ALB"
  
# }

output "open_webui_url" {
  value       = try(data.aws_lb.open_webui.dns_name, "") != "" ? "https://${var.Appsvar.Name}.${var.Appsvar.domain_name}" : "Waiting for ALB to provision..."
  description = "Open-WebUI URL"
}

output "open_webui_helm_release_status" {
  value       = helm_release.open-webui.status
  description = "Status of the Helm release"
}