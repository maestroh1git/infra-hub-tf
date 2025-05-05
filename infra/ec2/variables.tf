variable "region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "ami_id" {
  description = "AMI ID to use for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
}

variable "associate_public_ip_address" {
  description = "Whether to associate public IP addresses to instances"
  type        = bool
}

variable "subnet_ids" {
  description = "List of subnet IDs for EC2 instances"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs to attach to instances"
  type        = list(string)
}

variable "storage_size" {
  description = "Size of the root EBS volume in GB"
  type        = number
}

variable "attach_instance_profile" {
  description = "Whether to attach an IAM instance profile"
  type        = bool
}

variable "iam_role" {
  description = "IAM role name to attach to the instance profile"
  type        = string

}

variable "attach_eip" {
  description = "Whether to attach Elastic IPs to instances"
  type        = bool
  default     = true
}

variable "owner" {
  description = "Owner tag value"
  type        = string
}

variable "environment" {
  description = "Environment tag value"
  type        = string
}

variable "cost_center" {
  description = "Cost center tag value"
  type        = string
}

variable "application" {
  description = "Application tag value"
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {
    Project     = "MyProject"
    Terraform   = "true"
  }
}