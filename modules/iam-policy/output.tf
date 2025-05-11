# Outputs
output "ec2_role_name" {
  description = "EC2 IAM role name"
  value       = aws_iam_role.ec2_role.name
}

output "lambda_role_name" {
  description = "Lambda IAM role name"
  value       = aws_iam_role.lambda_role.name
}

output "developer_group_name" {
  description = "Developer IAM group name"
  value       = aws_iam_group.developers.name
}

output "admin_group_name" {
  description = "Admin IAM group name"
  value       = aws_iam_group.admins.name
}

output "readonly_group_name" {
  description = "Read-only IAM group name"
  value       = aws_iam_group.readonly.name
}

output "alb_role_name" {
  description = "ALB IAM role name"
  value       = aws_iam_role.alb_role.name
}

output "alb_role_arn" {
  description = "ALB IAM role ARN"
  value       = aws_iam_role.alb_role.arn
}
