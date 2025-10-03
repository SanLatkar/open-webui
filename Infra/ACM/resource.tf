# AWS Public Certificate with DNS Validation Method
resource "aws_acm_certificate" "certificate" {
  domain_name       = var.ACMvar.domain_name
  validation_method = "DNS"

  subject_alternative_names = [
    "*.${var.ACMvar.domain_name}"
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# AWS Route53 CNAME Record to Validate Certifiate
resource "aws_route53_record" "CNAME" {
  for_each = {
    for dvo in aws_acm_certificate.certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  allow_overwrite = true
  zone_id         = data.aws_route53_zone.hostedZone.zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = 60
}

# Validate ACM Certificate using Route53 CNAME Record
resource "aws_acm_certificate_validation" "certificateValidation" {
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.CNAME : record.fqdn]
}