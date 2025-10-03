# Variable function To call variable values for ACM module from root module.
variable "ACMvar" {
  type = object({
    Name = string
    domain_name = string
  })
}
