# EIPs for NAT Gateways
resource "aws_eip" "nat" {
  for_each = var.VPCvar.private_subnets

  depends_on = [aws_internet_gateway.EKS-igw]

  tags = {
    Name = "${var.VPCvar.Name}-${each.key}-eip"
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