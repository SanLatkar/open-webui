# Variable function To call variable values for Apps module from root module.
variable "Appsvar" {
  type = object({
    Name = string
    domain_name = string
    acm_certificate_arn = string
  })
}