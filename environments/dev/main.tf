terraform {
  backend "s3" {
    bucket         = "trila-infra-bucket"
    key            = "trila-backend/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "trila-backend-state-locks"
    encrypt        = true
  }
}

provider "aws" {
  region  = var.region
  profile = var.profile
}

module "vpc" {
  source                             = "../../modules/vpc"
  region                             = var.region
  vpc_cidr_block                     = var.vpc_cidr_block
  instance_tenancy                   = var.instance_tenancy
  enable_dns_support                 = var.enable_dns_support
  enable_dns_hostnames               = var.enable_dns_hostnames
  domain                             = var.domain
  create_nat_gateway                 = var.create_nat_gateway
  destination_cidr_block             = var.destination_cidr_block
  map_public_ip_on_launch            = var.map_public_ip_on_launch
  public_subnet_cidr_blocks          = var.public_subnet_cidr_blocks
  app_subnet_cidr_blocks             = var.app_subnet_cidr_blocks
  availability_zones                 = var.availability_zones
  create_s3_endpoint                 = var.create_s3_endpoint
  create_secrets_manager_endpoint    = var.create_secrets_manager_endpoint
  create_cloudwatch_logs_endpoint    = var.create_cloudwatch_logs_endpoint
  ingress_public_nacl_rule_no        = var.ingress_public_nacl_rule_no
  ingress_public_nacl_action         = var.ingress_public_nacl_action
  ingress_public_nacl_from_port      = var.ingress_public_nacl_from_port
  ingress_public_nacl_to_port        = var.ingress_public_nacl_to_port
  ingress_public_nacl_protocol       = var.ingress_public_nacl_protocol
  ingress_public_nacl_cidr_block     = var.ingress_public_nacl_cidr_block
  egress_public_nacl_rule_no         = var.egress_public_nacl_rule_no
  egress_public_nacl_action          = var.egress_public_nacl_action
  egress_public_nacl_from_port       = var.egress_public_nacl_from_port
  egress_public_nacl_to_port         = var.egress_public_nacl_to_port
  egress_public_nacl_protocol        = var.egress_public_nacl_protocol
  egress_public_nacl_cidr_block      = var.egress_public_nacl_cidr_block
  ingress_app_nacl_rule_no           = var.ingress_app_nacl_rule_no
  ingress_app_nacl_action            = var.ingress_app_nacl_action
  ingress_app_nacl_from_port         = var.ingress_app_nacl_from_port
  ingress_app_nacl_to_port           = var.ingress_app_nacl_to_port
  ingress_app_nacl_protocol          = var.ingress_app_nacl_protocol
  ingress_app_nacl_cidr_block        = var.ingress_app_nacl_cidr_block
  egress_app_nacl_rule_no            = var.egress_app_nacl_rule_no
  egress_app_nacl_action             = var.egress_app_nacl_action
  egress_app_nacl_from_port          = var.egress_app_nacl_from_port
  egress_app_nacl_to_port            = var.egress_app_nacl_to_port
  egress_app_nacl_protocol           = var.egress_app_nacl_protocol
  egress_app_nacl_cidr_block         = var.egress_app_nacl_cidr_block
  owner                              = var.owner
  environment                        = var.environment
  cost_center                        = var.cost_center
  application                        = var.application
}

module "security_group" {
  source              = "../../modules/sg"
  region              = var.region
  environment         = var.environment
  application         = var.application
  owner               = var.owner
  cost_center         = var.cost_center
  vpc_id              = var.vpc_id
  tags                = var.tags

  # Ingress rules for CIDR blocks
  create_ingress_cidr    = var.create_ingress_cidr
  ingress_cidr_from_port = var.ingress_cidr_from_port
  ingress_cidr_to_port   = var.ingress_cidr_to_port
  ingress_cidr_protocol  = var.ingress_cidr_protocol
  ingress_cidr_block     = var.ingress_cidr_block

  # Ingress rules for Security Groups
  create_ingress_sg            = var.create_ingress_sg
  ingress_sg_from_port         = var.ingress_sg_from_port1
  ingress_sg_to_port           = var.ingress_sg_to_port1
  ingress_sg_protocol          = var.ingress_sg_protocol
  ingress_security_group_ids   = var.ingress_security_group_ids

  # Egress rules for CIDR blocks
  create_egress_cidr     = var.create_egress_cidr
  egress_cidr_from_port  = var.egress_cidr_from_port
  egress_cidr_to_port    = var.egress_cidr_to_port
  egress_cidr_protocol   = var.egress_cidr_protocol
  egress_cidr_block      = var.egress_cidr_block1

  # Egress rules for Security Groups
  create_egress_sg           = var.create_egress_sg
  egress_sg_from_port        = var.egress_sg_from_port
  egress_sg_to_port          = var.egress_sg_to_port
  egress_sg_protocol         = var.egress_sg_protocol
  egress_security_group_ids  = var.egress_security_group_ids
}

module "state_lock" {
  source      = "../../modules/state_lock"
  environment = var.environment
  application = var.application
  owner       = var.owner
  cost_center = var.cost_center

  # DynamoDB Table Configuration
  billing_mode        = var.billing_mode
  hash_key            = var.hash_key
  attribute_name      = var.attribute_name
  attribute_type      = var.attribute_type

  tags = merge(
    {
      Name        = "${var.environment}-${var.application}-state-lock"
      Environment = var.environment,
      Owner       = var.owner,
      CostCenter  = var.cost_center,
      Application = var.application
    },
    var.tags
  )
}


module "iam" {
  source         = "../../modules/iam-policy"
  project_name   = var.project_name
  environment    = var.environment
  common_tags    = var.common_tags
  tags           = var.tags
  owner          = var.owner
  cost_center    = var.cost_center
  application    = var.application
}

module "ec2_instances" {
  source = "../../modules/ec2"
  
  region        = var.region
  ami_id        = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  
  instance_count                = var.instance_count
  associate_public_ip_address   = var.associate_public_ip_address
  subnet_ids                    = var.subnet_ids
  security_group_ids            = var.security_group_ids
  
  storage_size      = var.storage_size
  attach_eip        = var.attach_eip
  
  owner        = var.owner
  environment  = var.environment
  cost_center  = var.cost_center
  application  = var.application
  
  tags = var.tags
}

module "tag-policy" {
  source      = "../../modules/tag-policy"
  region      = var.region
  policy_name = var.policy_name
  policy_type = var.policy_type
  target_id   = var.target_id

  name_tag_key         = var.name_tag_key
  environment_tag_key  = var.environment_tag_key
  owner_tag_key        = var.owner_tag_key
  owner_tag_value      = var.owner_tag_value
  costcenter_tag_key   = var.costcenter_tag_key
  costcenter_tag_value = var.costcenter_tag_value
  application_tag_key  = var.application_tag_key
  enforce_for_values   = var.enforce_for_values
} 

/*module "acm" {
  source = "../../modules/acm"
  region = var.region

  domain_name                                 = var.domain_name
  validation_method                           = var.validation_method
  key_algorithm                               = var.key_algorithm
  certificate_transparency_logging_preference = var.certificate_transparency_logging_preference
  dns_domain_name = var.dns_domain_name
  
  name        = var.name
  environment = var.environment
  owner       = var.owner
  cost_center = var.cost_center
  application = var.application
}*/