# Subnets for the VPC
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

# NAT Gateways (one per private subnet)
resource "aws_nat_gateway" "main" {
  for_each = var.VPCvar.private_subnets

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.main["public-${each.value.az_index + 1}"].id

  tags = {
    Name = "${var.VPCvar.Name}-${each.key}-nat"
  }

  depends_on = [aws_internet_gateway.EKS-igw]
}

# EIPs for NAT Gateways
resource "aws_eip" "nat" {
  for_each = var.VPCvar.private_subnets

  depends_on = [aws_internet_gateway.EKS-igw]

  tags = {
    Name = "${var.VPCvar.Name}-${each.key}-eip"
  }
}

