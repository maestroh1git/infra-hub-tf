provider "aws" {
  region = var.region
}

module "iam" {
  source         = "../../modules/iam"
  project_name   = var.project_name
  environment    = var.environment
  common_tags    = var.common_tags
  tags           = var.tags
  owner          = var.owner
  cost_center    = var.cost_center
  application    = var.application
}