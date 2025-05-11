# Variable definitions
variable "tags" {
  default     = {}
  type        = map(string)
  description = "Extra tags to attach to the iam-policy"
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
  description = "Name of cost-center for this alb-asg"
}

variable "application" {
  type        = string
  description = "Name of application"
}

# Project name variable (already used in the original code)
variable "project_name" {
  type        = string
  description = "Name of the project"
}

# Common tags variable (already used in the original code)
variable "common_tags" {
  type        = map(string)
  description = "Common tags to apply to all resources"
  default     = {}
}