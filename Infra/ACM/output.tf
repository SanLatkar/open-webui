# Output the ARN of the ACM Certificate
output "acm_certificate_arn" {
  value       = aws_acm_certificate.certificate.arn
  description = "ARN of the ACM Certificate"
  
}