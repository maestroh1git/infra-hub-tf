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

variable "kms_key_arn" {
  type        = string
  description = "KMS key ARN for backup encryption"
}

variable "backup_schedule" {
  type        = string
  description = "Cron expression for backup schedule"
  default     = "cron(0 5 ? * * *)" # Daily at 5 AM UTC
}

variable "backup_retention_days" {
  type        = number
  description = "Number of days to retain backups"
  default     = 30
}

variable "cold_storage_after_days" {
  type        = number
  description = "Number of days before moving to cold storage (minimum 90)"
  default     = null
}

variable "enable_notifications" {
  type        = bool
  description = "Enable SNS notifications for backup events"
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Additional tags"
  default     = {}
}
