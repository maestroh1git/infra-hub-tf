variable "region" {
  type        = string
  description = "The AWS region where resources will be created."
}

variable "vpc_cidr_block" {}
variable "instance_tenancy" {}
variable "enable_dns_support" {}
variable "enable_dns_hostnames" {}
variable "domain" {}
variable "create_nat_gateway" {}
variable "destination_cidr_block" {}
variable "map_public_ip_on_launch" {}
variable "public_subnet_cidr_blocks" {
  type = list(string)
}
variable "app_subnet_cidr_blocks" {
  type = list(string)
}
variable "availability_zones" {
  type = list(string)
}
variable "create_s3_endpoint" {}
variable "create_secrets_manager_endpoint" {}
variable "create_cloudwatch_logs_endpoint" {}

# Public NACL
variable "ingress_public_nacl_rule_no" {}
variable "ingress_public_nacl_action" {}
variable "ingress_public_nacl_from_port" {}
variable "ingress_public_nacl_to_port" {}
variable "ingress_public_nacl_protocol" {}
variable "ingress_public_nacl_cidr_block" {}

variable "egress_public_nacl_rule_no" {}
variable "egress_public_nacl_action" {}
variable "egress_public_nacl_from_port" {}
variable "egress_public_nacl_to_port" {}
variable "egress_public_nacl_protocol" {}
variable "egress_public_nacl_cidr_block" {}

# App NACL
variable "ingress_app_nacl_rule_no" {}
variable "ingress_app_nacl_action" {}
variable "ingress_app_nacl_from_port" {}
variable "ingress_app_nacl_to_port" {}
variable "ingress_app_nacl_protocol" {}
variable "ingress_app_nacl_cidr_block" {}

variable "egress_app_nacl_rule_no" {}
variable "egress_app_nacl_action" {}
variable "egress_app_nacl_from_port" {}
variable "egress_app_nacl_to_port" {}
variable "egress_app_nacl_protocol" {}
variable "egress_app_nacl_cidr_block" {}

variable "domain_name" {
  type        = string
  description = "The domain name associated with the SSL/TLS certificate."
}

variable "validation_method" {
  type        = string
  description = "The validation method used for certificate issuance (e.g., DNS, email)."
}

variable "key_algorithm" {
  type        = string
  description = "The cryptographic key algorithm used for the certificate (e.g., RSA, ECDSA)."
}

variable "certificate_transparency_logging_preference" {
  type        = string
  description = "The logging preference for certificate transparency (e.g., 'ENABLED' or 'DISABLED')."
}

variable "name" {
  type        = string
  description = "A user-defined name for the AWS resources."
}

variable "dns_domain_name" {
  type        = string
  description = "Domain name of the Route 53"
}

# Common variables used across resources
variable "tags" {
  default     = {}
  type        = map(string)
  description = "A map of extra tags to attach to the AWS resources."
}

variable "owner" {
  type        = string
  description = "Name of owner"
}

variable "environment" {
  type        = string
  description = "The environment name for the resources."
}

variable "cost_center" {
  type        = string
  description = "Name of cost-center for the resources."
}

variable "application" {
  type        = string
  description = "Name of the application"
}

variable "profile" {
  type        = string
  description = "AWS profile to use"
}

# DynamoDB specific variables
variable "billing_mode" {
  type        = string
  description = "Billing mode for dynamodb"
}

variable "hash_key" {
  type        = string
  description = "Hash key name of dynamodb"
}

variable "attribute_name" {
  type        = string
  description = "Attribute name of dynamodb"
}

variable "attribute_type" {
  type        = string
  description = "Attribute type of dynamodb"
}

# EC2 Instance Variables
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

variable "attach_eip" {
  description = "Whether to attach Elastic IPs to instances"
  type        = bool
  default     = true
}

variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "egress_cidr_block" {
  description = "The CIDR block for the egress rule"
  type        = string
}

variable "create_ingress_sg" {
  description = "Flag to create ingress security group"
  type        = bool
  default     = false
}

variable "ingress_sg_from_port" {
  description = "The starting port for the ingress security group rule"
  type        = number
}

variable "ingress_sg_to_port" {
  description = "The ending port for the ingress security group rule"
  type        = number
}



variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
}

# Ingress - CIDR
variable "create_ingress_cidr" {
  description = "Whether to create ingress rules from CIDR blocks"
  type        = bool
}

variable "ingress_cidr_from_port" {
  description = "List of starting ports for ingress from CIDR"
  type        = list(number)
}

variable "ingress_cidr_to_port" {
  description = "List of ending ports for ingress from CIDR"
  type        = list(number)
}

variable "ingress_cidr_protocol" {
  description = "List of protocols for ingress from CIDR"
  type        = list(string)
}

variable "ingress_cidr_block" {
  description = "List of CIDR blocks for ingress"
  type        = list(string)
}

# Ingress - Security Group

variable "ingress_sg_from_port1" {}

variable "ingress_sg_to_port1" {
  description = "List of ending ports for ingress from SG"
  type        = list(number)
}

variable "ingress_sg_protocol" {
  description = "List of protocols for ingress from SG"
  type        = list(string)
}

variable "ingress_security_group_ids" {
  description = "List of security group IDs for ingress rules"
  type        = list(string)
}

# Egress - CIDR
variable "create_egress_cidr" {
  description = "Whether to create egress rules to CIDR blocks"
  type        = bool
}

variable "egress_cidr_from_port" {
  description = "List of starting ports for egress to CIDR"
  type        = list(number)
}

variable "egress_cidr_to_port" {
  description = "List of ending ports for egress to CIDR"
  type        = list(number)
}

variable "egress_cidr_protocol" {
  description = "List of protocols for egress to CIDR"
  type        = list(string)
}

variable "egress_cidr_block1" {
  description = "List of CIDR blocks for egress"
  type        = list(string)
}

# Egress - Security Group
variable "create_egress_sg" {
  description = "Whether to create egress rules to other security groups"
  type        = bool
}

variable "egress_sg_from_port" {
  description = "List of starting ports for egress to SG"
  type        = list(number)
}

variable "egress_sg_to_port" {
  description = "List of ending ports for egress to SG"
  type        = list(number)
}

variable "egress_sg_protocol" {
  description = "List of protocols for egress to SG"
  type        = list(string)
}

variable "egress_security_group_ids" {
  description = "List of security group IDs for egress rules"
  type        = list(string)
}

variable "policy_name" {
  description = "The name of the policy"
  type        = string
}

variable "policy_type" {
  description = "The type of the policy"
  type        = string
}

variable "target_id" {
  description = "The target ID for the policy"
  type        = string
}

variable "name_tag_key" {
  description = "The tag key for Name"
  type        = string
}

variable "environment_tag_key" {
  description = "The tag key for Environment"
  type        = string
}

variable "owner_tag_key" {
  description = "The tag key for Owner"
  type        = string
}

variable "owner_tag_value" {
  description = "The tag value for the Owner"
}


variable "costcenter_tag_key" {
  description = "The tag key for Cost Center"
  type        = string
}

variable "costcenter_tag_value" {
  description = "The tag value for Cost Center"
}

variable "application_tag_key" {
  description = "The tag key for Application"
  type        = string
}

variable "enforce_for_values" {
  description = "List of values the policy should enforce"
  type        = list(string)
}

