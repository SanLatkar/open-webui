# VPC for EKS Cluster
resource "aws_vpc" "EKS-vpc" {
  # The CIDR block for the VPC.
  cidr_block = "192.168.0.0/16"

  # Makes your instances shared on the host.
  instance_tenancy = "default"

  # Required for EKS. Enable/disable DNS support in the VPC.
  enable_dns_support = true

  # Required for EKS. Enable/disable DNS hostnames in the VPC.
  enable_dns_hostnames = true

  # Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC.
  assign_generated_ipv6_cidr_block = false

  # A map of tags to assign to the resource.
  tags = {
    Name = var.VPCvar.Name
  }
}

# Internet Gateway for the VPC
resource "aws_internet_gateway" "EKS-igw" {
  # The VPC ID to create in.
  vpc_id = aws_vpc.EKS-vpc.id

  # A map of tags to assign to the resource.
  tags = {
    Name = var.VPCvar.Name
  }
}
