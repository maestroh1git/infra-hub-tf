output "instance_ids" {
  description = "IDs of the created EC2 instances"
  value       = module.ec2_instances.instance_ids
}

output "instance_arns" {
  description = "ARNs of the created EC2 instances"
  value       = module.ec2_instances.instance_arns
}

output "instance_private_ips" {
  description = "Private IP addresses of the created EC2 instances"
  value       = module.ec2_instances.instance_private_ips
}

output "instance_public_ips" {
  description = "Public IP addresses of the created EC2 instances, if applicable"
  value       = module.ec2_instances.instance_public_ips
}

output "eip_ids" {
  description = "IDs of the Elastic IPs attached to instances, if applicable"
  value       = module.ec2_instances.eip_ids
}

output "eip_public_ips" {
  description = "Public IP addresses of the Elastic IPs, if applicable"
  value       = module.ec2_instances.eip_public_ips
}

output "instance_security_groups" {
  description = "Security groups attached to the EC2 instances"
  value       = module.ec2_instances.instance_security_groups
}

output "iam_instance_profile_name" {
  description = "Name of the IAM instance profile attached to instances, if applicable"
  value       = module.ec2_instances.iam_instance_profile_name
}

output "iam_instance_profile_arn" {
  description = "ARN of the IAM instance profile attached to instances, if applicable"
  value       = module.ec2_instances.iam_instance_profile_arn
}

output "instance_tags" {
  description = "Tags applied to the EC2 instances"
  value       = module.ec2_instances.instance_tags
}

output "instance_primary_network_interface_ids" {
  description = "IDs of the primary network interfaces of the EC2 instances"
  value       = module.ec2_instances.instance_primary_network_interface_ids
}