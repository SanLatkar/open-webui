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

# Map of private subnet IDs
variable "private_subnet_ids" {
  description = "Map of private subnet IDs"
  type        = map(string)
}

# Map of public subnet IDs
variable "public_subnet_ids" {
  description = "Map of public subnet IDs"
  type        = map(string)
}