variable "VPCvar" {
  type = object({
    Name = string,
    subnets = map(object({
      cidr_block = string
      az_index   = number
      type       = string
    }))
    public_subnets = map(object({
      cidr_block = string
      az_index   = number
      type       = string
    }))
    private_subnets = map(object({
      cidr_block = string
      az_index   = number
      type       = string
    }))
  })
  
}