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

variable "deletion_window_in_days" {
  type        = number
  description = "Duration in days before the key is deleted after destruction"
  default     = 30
}

variable "enable_key_rotation" {
  type        = bool
  description = "Enable automatic key rotation"
  default     = true
}

variable "multi_region" {
  type        = bool
  description = "Indicates whether the KMS key is a multi-Region key"
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Additional tags"
  default     = {}
}
