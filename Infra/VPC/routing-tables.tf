

# Public route table (one for all public subnets)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.EKS-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.EKS-igw.id
  }

  tags = {
    Name = "${var.VPCvar.Name}-public-routetable"
  }
}

# Private route tables (one per private subnet/NAT gateway)
resource "aws_route_table" "private" {
  for_each = var.VPCvar.private_subnets

  vpc_id = aws_vpc.EKS-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[each.key].id
  }

  tags = {
    Name = "${var.VPCvar.Name}-${each.key}-routetable"
  }
}