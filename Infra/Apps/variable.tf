variable "Appsvar" {
  type = object({
    Name = string
    domain_name = string
    acm_certificate_arn = string
  })
}