# Variable function To call variable values for EFS module from root module.
variable "ALBvar" {
  type = object({
    openid_provider_arn = string
    openid_provider_url = string
    Name = string
    region = string
    vpc_id = string
    domain_name = string
    acm_certificate_arn = string
  })
}


resource "aws_iam_policy" "AWSLoadBalancerControllerIAMPolicy" {
  name        = "${var.ALBvar.Name}-AWSLoadBalancerControllerIAMPolicy"
  description = "policy for the ALB Controller"
  
  policy = file("ALBiam_policy.json")

  tags = {
    Name = "${var.ALBvar.Name}-AWSLoadBalancerControllerIAMPolicy"
  }
}

resource "aws_iam_role" "AmazonEKSLoadBalancerControllerRole" {
  # The name of the role
  name = "${var.ALBvar.Name}-AmazonEKSLoadBalancerControllerRole"

  # The policy that grants an entity permission to assume the role.
  # Used to access AWS resources that you might not normally have access to.
  # The role that Amazon EKS will use to create AWS resources for Kubernetes clusters
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${var.ALBvar.openid_provider_arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${substr(var.ALBvar.openid_provider_url,8,-1)}:aud": "sts.amazonaws.com",
          "${substr(var.ALBvar.openid_provider_url,8,-1)}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
        }
      }
    }
  ]
}
POLICY

  tags = {
    Name = "${var.ALBvar.Name}-AmazonEKSLoadBalancerControllerRole"
  }
}


resource "aws_iam_role_policy_attachment" "AmazonEKSLoadBalancerControllerRolePolicyAttachment" {
  policy_arn = aws_iam_policy.AWSLoadBalancerControllerIAMPolicy.arn
  role       = aws_iam_role.AmazonEKSLoadBalancerControllerRole.name
}

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.13.0"

  values = [
    templatefile("${path.module}/aws-alb-values.yaml", {
      cluster_name = var.ALBvar.Name
      role_arn     = aws_iam_role.AmazonEKSLoadBalancerControllerRole.arn
    })
  ]

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSLoadBalancerControllerRolePolicyAttachment
  ]
}

output "alb_controller_role_arn" {
  value       = aws_iam_role.AmazonEKSLoadBalancerControllerRole.arn
  description = "ARN of IAM role for AWS Load Balancer Controller"
}

output "alb_controller_policy_arn" {
  value       = aws_iam_policy.AWSLoadBalancerControllerIAMPolicy.arn
  description = "ARN of IAM policy for AWS Load Balancer Controller"
}

output "helm_release_status" {
  value       = helm_release.aws_load_balancer_controller.status
  description = "Status of the Helm release"
}