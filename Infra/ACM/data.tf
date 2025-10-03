data "aws_route53_zone" "hostedZone" {
  name         = var.ACMvar.domain_name
  private_zone = false
}