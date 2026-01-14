# VPC Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "app_subnet_ids" {
  description = "List of application subnet IDs"
  value       = module.vpc.app_subnet_ids
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = module.vpc.nat_gateway_ids
}

# Security Group Outputs
output "security_group_id" {
  description = "The ID of the security group"
  value       = module.security_group.security_group_id
}

# EC2 Outputs
output "ec2_instance_ids" {
  description = "List of EC2 instance IDs"
  value       = module.ec2_instances.instance_ids
}

output "ec2_private_ips" {
  description = "List of EC2 private IP addresses"
  value       = module.ec2_instances.private_ips
}

output "ec2_public_ips" {
  description = "List of EC2 public IP addresses (if EIP attached)"
  value       = module.ec2_instances.public_ips
}

# IAM Outputs
output "iam_policy_arns" {
  description = "Map of IAM policy ARNs"
  value       = module.iam.policy_arns
}

# DynamoDB State Lock Output
output "dynamodb_table_name" {
  description = "The name of the DynamoDB table for state locking"
  value       = module.state_lock.dynamodb_table_name
}

output "dynamodb_table_arn" {
  description = "The ARN of the DynamoDB table for state locking"
  value       = module.state_lock.dynamodb_table_arn
}

# Region Output
output "aws_region" {
  description = "The AWS region resources are created in"
  value       = var.region
}

# Environment Output
output "environment" {
  description = "The environment name"
  value       = var.environment
}
