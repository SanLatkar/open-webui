# output "alb_controller_role_arn" {
#   value       = aws_iam_role.AmazonEKSLoadBalancerControllerRole.arn
#   description = "ARN of IAM role for AWS Load Balancer Controller"
# }

# # Output the ARN of the IAM policy
# output "alb_controller_policy_arn" {
#   value       = aws_iam_policy.AWSLoadBalancerControllerIAMPolicy.arn
#   description = "ARN of IAM policy for AWS Load Balancer Controller"
# }

# # 
# output "helm_release_status" {
#   value       = helm_release.aws_load_balancer_controller.status
#   description = "Status of the Helm release"
# }