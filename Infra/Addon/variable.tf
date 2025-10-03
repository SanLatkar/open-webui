# Variable function To call variable values for EFS module from root module.
variable "Addonvar" {
  type = object({
    openid_provider_arn = string
    openid_provider_url = string
    Name = string
    region = string
    vpc_id = string
    domain_name = string
    acm_certificate_arn = string
  })
}
