# Variable function To call variable values for EFS module from root module.
variable "ALBvar" {
  type = object({
    OpenidARN = string
    OpenidProvider = string
    Name = string
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
        "Federated": "${var.ALBvar.OpenidARN}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${substr(var.ALBvar.OpenidProvider,8,-1)}:aud": "sts.amazonaws.com",
          "${substr(var.ALBvar.OpenidProvider,8,-1)}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
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