

# Public subnet associations (all use same route table)
resource "aws_route_table_association" "public" {
  for_each = var.VPCvar.public_subnets

  subnet_id      = aws_subnet.main[each.key].id
  route_table_id = aws_route_table.public.id
}

# Private subnet associations (each uses own route table)
resource "aws_route_table_association" "private" {
  for_each = var.VPCvar.private_subnets

  subnet_id      = aws_subnet.main[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}