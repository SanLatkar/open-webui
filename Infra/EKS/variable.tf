# Variable function To call variable values for EKS module from root module.
variable "EKSvar" {
  type = object({
    ami_type = string
    instance_types = string
    k8_version = string
    Name = string
    desired_nodegorup_size = number
    disk_size = number
    capacity_type = string

  })
}

# variable "VPCvar" {
#   type = object({
#     subnets = map(object({
#       cidr_block = string
#       az_index   = number
#       type       = string
#     }))
#     public_subnets = map(object({
#       cidr_block = string
#       az_index   = number
#       type       = string
#     }))
#     private_subnets = map(object({
#       cidr_block = string
#       az_index   = number
#       type       = string
#     }))
#   })
  
# }


variable "private_subnet_ids" {
  description = "Map of private subnet IDs"
  type        = map(string)
}

variable "public_subnet_ids" {
  description = "Map of public subnet IDs"
  type        = map(string)
}