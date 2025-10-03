# IAM role for EKS Node Group
resource "aws_iam_role" "nodes_group" {
  # The name of the role
  name = "${var.EKSvar.Name}-node-group"

  # The policy that grants an entity permission to assume the role.
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }, 
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
  tags = {
    Name = "${var.EKSvar.Name}-node-group-role"
  }
}

locals {
  node_group_policies = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ])
}

# Launch Template for EKS Node Group
resource "aws_launch_template" "launch_template" {
  name   = "${var.EKSvar.Name}-launch-template"
  # instance_type = var.EKSvar.instance_types

  metadata_options {
    http_tokens = "required"
    http_put_response_hop_limit = 2
    http_endpoint = "enabled"
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = var.EKSvar.disk_size
      volume_type = "gp3"
      delete_on_termination = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
  
}

# IAM Role Policy Attachments for EKS Node Group
resource "aws_iam_role_policy_attachment" "nodes_group" {
  for_each   = local.node_group_policies
  policy_arn = each.value
  role       = aws_iam_role.nodes_group.name
}

# EKS Node Group
resource "aws_eks_node_group" "nodes_group" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${var.EKSvar.Name}-nodes-group"
  node_role_arn   = aws_iam_role.nodes_group.arn
  subnet_ids = values(var.private_subnet_ids)

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }

  scaling_config {
    desired_size = var.EKSvar.desired_nodegorup_size
    max_size     = 3
    min_size     = 1
  }
  
  ami_type       = var.EKSvar.ami_type
  capacity_type  = var.EKSvar.capacity_type
  instance_types = [var.EKSvar.instance_types]
  version        = var.EKSvar.k8_version

  labels = {
    role = "nodes-group"
  }

  force_update_version = false

  depends_on = [
    aws_iam_role_policy_attachment.nodes_group
  ]

  tags = {
    Name = "${var.EKSvar.Name}-nodes-group"
  }
}