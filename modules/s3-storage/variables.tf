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

variable "bucket_suffix" {
  type        = string
  description = "Unique suffix for bucket names (e.g., account ID or random string)"
}

variable "kms_key_id" {
  type        = string
  description = "KMS key ID for bucket encryption"
}

variable "create_assets_bucket" {
  type        = bool
  description = "Whether to create the assets bucket"
  default     = true
}

# Logs bucket lifecycle
variable "logs_transition_to_ia_days" {
  type        = number
  description = "Days before transitioning logs to Infrequent Access"
  default     = 30
}

variable "logs_transition_to_glacier_days" {
  type        = number
  description = "Days before transitioning logs to Glacier"
  default     = 90
}

variable "logs_expiration_days" {
  type        = number
  description = "Days before expiring logs"
  default     = 365
}

# Backups bucket lifecycle
variable "backups_transition_to_ia_days" {
  type        = number
  description = "Days before transitioning backups to Infrequent Access"
  default     = 60
}

variable "backups_transition_to_glacier_days" {
  type        = number
  description = "Days before transitioning backups to Glacier"
  default     = 180
}

variable "backups_expiration_days" {
  type        = number
  description = "Days before expiring backups"
  default     = 730
}

variable "tags" {
  type        = map(string)
  description = "Additional tags"
  default     = {}
}
