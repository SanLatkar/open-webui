output "vpc_id" {
  value       = aws_vpc.EKS-vpc.id
  description = "VPC id."
  # Setting an output value as sensitive prevents Terraform from showing its value in plan and apply.
  sensitive = false
}

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