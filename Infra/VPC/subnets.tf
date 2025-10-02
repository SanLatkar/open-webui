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

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "main" {
  for_each = var.VPCvar.subnets

  vpc_id                  = aws_vpc.EKS-vpc.id
  cidr_block              = each.value.cidr_block
  availability_zone       = data.aws_availability_zones.available.names[each.value.az_index]
  map_public_ip_on_launch = each.value.type == "public" ? true : false

  tags = {
    Name                                    = "${var.VPCvar.Name}-${each.key}-subnet"
    "kubernetes.io/cluster/${var.VPCvar.Name}"             = "shared"
    "kubernetes.io/role/${each.value.type == "public" ? "elb" : "internal-elb"}" = 1
  }
}

# Outputs
output "public_subnet_ids" {
  value = {
    for key, subnet in aws_subnet.main : key => subnet.id
    if subnet.map_public_ip_on_launch == true
  }
}

output "private_subnet_ids" {
  value = {
    for key, subnet in aws_subnet.main : key => subnet.id
    if subnet.map_public_ip_on_launch == false
  }
}
