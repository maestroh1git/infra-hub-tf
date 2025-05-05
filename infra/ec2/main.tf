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
  
  # Root volume configuration
  storage_size      = var.storage_size
  
  # Optional IAM role attachment
  attach_instance_profile = var.attach_instance_profile
  iam_role                = var.iam_role
  
  # Optional EIP attachment
  attach_eip = var.attach_eip
  
  # Common tags
  owner        = var.owner
  environment  = var.environment
  cost_center  = var.cost_center
  application  = var.application
  
  tags = var.tags
}