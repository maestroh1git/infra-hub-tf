# AWS Configuration
region  = "us-east-2"
profile = "default"

# Project Configuration
project_name = "maestrohwithit"
application  = "maestrohwithit"
environment  = "staging"
owner        = "DevOps Team"
cost_center  = "Engineering"

# VPC Configuration (different CIDR for staging)
vpc_cidr_block       = "10.1.0.0/16"
instance_tenancy     = "default"
enable_dns_support   = true
enable_dns_hostnames = true
domain               = "vpc"
create_nat_gateway   = true
destination_cidr_block    = "0.0.0.0/0"
map_public_ip_on_launch   = true

# Subnet Configuration (different CIDR for staging)
public_subnet_cidr_blocks = ["10.1.1.0/24", "10.1.2.0/24"]
app_subnet_cidr_blocks    = ["10.1.4.0/24", "10.1.5.0/24"]
availability_zones        = ["us-east-2a", "us-east-2b"] # Only 2 AZs for staging to save cost

# VPC Endpoints
create_s3_endpoint                = true
create_secrets_manager_endpoint   = true
create_cloudwatch_logs_endpoint   = true

# Public NACL Configuration
ingress_public_nacl_rule_no    = [100, 200]
ingress_public_nacl_action     = ["allow", "allow"]
ingress_public_nacl_from_port  = [80, 443]
ingress_public_nacl_to_port    = [80, 443]
ingress_public_nacl_protocol   = ["tcp", "tcp"]
ingress_public_nacl_cidr_block = ["0.0.0.0/0", "0.0.0.0/0"]

egress_public_nacl_rule_no    = [100]
egress_public_nacl_action     = ["allow"]
egress_public_nacl_from_port  = [0]
egress_public_nacl_to_port    = [0]
egress_public_nacl_protocol   = ["-1"]
egress_public_nacl_cidr_block = ["0.0.0.0/0"]

# App NACL Configuration
ingress_app_nacl_rule_no    = [100]
ingress_app_nacl_action     = ["allow"]
ingress_app_nacl_from_port  = [0]
ingress_app_nacl_to_port    = [0]
ingress_app_nacl_protocol   = ["-1"]
ingress_app_nacl_cidr_block = ["0.0.0.0/0"]

egress_app_nacl_rule_no    = [100]
egress_app_nacl_action     = ["allow"]
egress_app_nacl_from_port  = [0]
egress_app_nacl_to_port    = [0]
egress_app_nacl_protocol   = ["-1"]
egress_app_nacl_cidr_block = ["0.0.0.0/0"]

# Domain Configuration
domain_name                                 = "maestrohwithit-staging.com"
dns_domain_name                             = "maestrohwithit-staging.com"
validation_method                           = "DNS"
key_algorithm                               = "RSA_2048"
certificate_transparency_logging_preference = "ENABLED"
name                                        = "maestrohwithit-staging-cert"

# Security Group Configuration (placeholder - replace with actual VPC ID after creation)
vpc_id = "vpc-placeholder" # Update after VPC is created

# Ingress CIDR Rules
create_ingress_cidr    = true
ingress_cidr_from_port = [80, 443, 22]
ingress_cidr_to_port   = [80, 443, 22]
ingress_cidr_protocol  = ["tcp", "tcp", "tcp"]
ingress_cidr_block     = ["0.0.0.0/0", "0.0.0.0/0", "0.0.0.0/0"]

# Ingress Security Group Rules
create_ingress_sg        = false
ingress_sg_from_port1    = []
ingress_sg_to_port1      = []
ingress_sg_protocol      = []
ingress_security_group_ids = []

# Egress CIDR Rules
create_egress_cidr     = true
egress_cidr_from_port  = [0]
egress_cidr_to_port    = [0]
egress_cidr_protocol   = ["-1"]
egress_cidr_block1     = ["0.0.0.0/0"]
egress_cidr_block      = "0.0.0.0/0"

# Egress Security Group Rules
create_egress_sg          = false
egress_sg_from_port       = []
egress_sg_to_port         = []
egress_sg_protocol        = []
egress_security_group_ids = []

# DynamoDB State Lock Configuration
billing_mode   = "PAY_PER_REQUEST"
hash_key       = "LockID"
attribute_name = "LockID"
attribute_type = "S"

# EC2 Configuration
ami_id                      = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2 - Update with latest AMI
instance_type               = "t3.small"  # Slightly larger for staging
key_name                    = "maestrohwithit-staging-key"
instance_count              = 1
associate_public_ip_address = true
subnet_ids                  = [] # Will be populated from VPC outputs
security_group_ids          = [] # Will be populated from security group outputs
storage_size                = 20
attach_instance_profile     = false
attach_eip                  = false

# Tag Policy Configuration
policy_name              = "maestrohwithitTa gPolicy"
policy_type              = "TAG_POLICY"
target_id                = "" # AWS Organization or OU ID
name_tag_key             = "Name"
environment_tag_key      = "Environment"
owner_tag_key            = "Owner"
owner_tag_value          = ["DevOps Team"]
costcenter_tag_key       = "CostCenter"
costcenter_tag_value     = ["Engineering"]
application_tag_key      = "Application"
enforce_for_values       = ["maestrohwithit"]

# Common Tags
tags = {
  ManagedBy = "Terraform"
  Project   = "maestrohwithit"
}

common_tags = {
  ManagedBy = "Terraform"
  Project   = "maestrohwithit"
}
