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

variable "vpc_id" {
  type        = string
  description = "VPC ID to enable flow logs for"
}

variable "traffic_type" {
  type        = string
  description = "Type of traffic to log (ACCEPT, REJECT, or ALL)"
  default     = "ALL"

  validation {
    condition     = contains(["ACCEPT", "REJECT", "ALL"], var.traffic_type)
    error_message = "Traffic type must be ACCEPT, REJECT, or ALL."
  }
}

variable "log_retention_days" {
  type        = number
  description = "Number of days to retain flow logs"
  default     = 30
}

variable "kms_key_id" {
  type        = string
  description = "KMS key ID for log encryption"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Additional tags"
  default     = {}
}
