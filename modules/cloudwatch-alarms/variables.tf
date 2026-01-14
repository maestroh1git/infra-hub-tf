variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"
}

variable "application" {
  type        = string
  description = "Application name"
}

variable "owner" {
  type        = string
  description = "Owner of the resources"
}

variable "cost_center" {
  type        = string
  description = "Cost center for billing"
}

variable "alarm_email" {
  type        = string
  description = "Email address for alarm notifications"
  default     = ""
}

# EC2 Alarms
variable "enable_ec2_alarms" {
  type        = bool
  description = "Enable EC2 CloudWatch alarms"
  default     = true
}

variable "ec2_instance_ids" {
  type        = list(string)
  description = "List of EC2 instance IDs to monitor"
  default     = []
}

variable "ec2_cpu_threshold" {
  type        = number
  description = "CPU utilization threshold for EC2 alarms (percentage)"
  default     = 80
}

# RDS Alarms
variable "enable_rds_alarms" {
  type        = bool
  description = "Enable RDS CloudWatch alarms"
  default     = true
}

variable "rds_instance_id" {
  type        = string
  description = "RDS instance identifier to monitor"
  default     = ""
}

variable "rds_cpu_threshold" {
  type        = number
  description = "CPU utilization threshold for RDS alarms (percentage)"
  default     = 80
}

variable "rds_storage_threshold" {
  type        = number
  description = "Free storage space threshold for RDS (bytes, e.g., 10GB = 10737418240)"
  default     = 10737418240
}

variable "rds_connections_threshold" {
  type        = number
  description = "Database connections threshold for RDS"
  default     = 80
}

# ALB Alarms
variable "enable_alb_alarms" {
  type        = bool
  description = "Enable ALB CloudWatch alarms"
  default     = true
}

variable "alb_arn_suffix" {
  type        = string
  description = "ALB ARN suffix for monitoring"
  default     = ""
}

variable "target_group_arn_suffix" {
  type        = string
  description = "Target group ARN suffix for monitoring"
  default     = ""
}

variable "alb_response_time_threshold" {
  type        = number
  description = "Target response time threshold in seconds"
  default     = 1
}

variable "unhealthy_host_threshold" {
  type        = number
  description = "Unhealthy host count threshold"
  default     = 0
}

# EKS Alarms
variable "enable_eks_alarms" {
  type        = bool
  description = "Enable EKS CloudWatch alarms"
  default     = true
}

variable "eks_cluster_name" {
  type        = string
  description = "EKS cluster name to monitor"
  default     = ""
}

variable "eks_cpu_threshold" {
  type        = number
  description = "CPU utilization threshold for EKS nodes (percentage)"
  default     = 80
}

variable "tags" {
  type        = map(string)
  description = "Additional tags"
  default     = {}
}
