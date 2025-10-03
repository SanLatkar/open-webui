# IAM policy for ALB Controller
resource "aws_iam_policy" "AWSLoadBalancerControllerIAMPolicy" {
  name        = "${var.Addonvar.Name}-AWSLoadBalancerControllerIAMPolicy"
  description = "policy for the ALB Controller"
  
  policy = file("ALBiam_policy.json")

  tags = {
    Name = "${var.Addonvar.Name}-AWSLoadBalancerControllerIAMPolicy"
  }
}

# IAM role for ALB Controller
resource "aws_iam_role" "AmazonEKSLoadBalancerControllerRole" {
  # The name of the role
  name = "${var.Addonvar.Name}-AmazonEKSLoadBalancerControllerRole"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${var.Addonvar.openid_provider_arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${substr(var.Addonvar.openid_provider_url,8,-1)}:aud": "sts.amazonaws.com",
          "${substr(var.Addonvar.openid_provider_url,8,-1)}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
        }
      }
    }
  ]
}
POLICY

  tags = {
    Name = "${var.Addonvar.Name}-AmazonEKSLoadBalancerControllerRole"
  }
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "AmazonEKSLoadBalancerControllerRolePolicyAttachment" {
  policy_arn = aws_iam_policy.AWSLoadBalancerControllerIAMPolicy.arn
  role       = aws_iam_role.AmazonEKSLoadBalancerControllerRole.name
}

# Helm chart for ALB Controller
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.13.0"

  values = [
    templatefile("${path.module}/values/aws-alb-values.yaml", {
      cluster_name = var.Addonvar.Name
      role_arn     = aws_iam_role.AmazonEKSLoadBalancerControllerRole.arn
    })
  ]

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSLoadBalancerControllerRolePolicyAttachment
  ]
}