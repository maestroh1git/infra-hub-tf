variable "environment" {
  description = "The environment for the resources (e.g., dev, prod)"
  type        = string
}

variable "application" {
  description = "The name of the application"
  type        = string
}

variable "owner" {
  description = "The owner of the resources"
  type        = string
}

variable "cost_center" {
  description = "The cost center for the resources"
  type        = string
}

variable "tags" {
  description = "Additional tags for the resources"
  type        = map(string)
  default     = {}
}

variable "billing_mode" {
  description = "Billing mode for DynamoDB table (e.g., PAY_PER_REQUEST or PROVISIONED)"
  type        = string
}

variable "hash_key" {
  description = "The hash key for DynamoDB table"
  type        = string
}

variable "attribute_name" {
  description = "The name of the attribute for DynamoDB table"
  type        = string
}

variable "attribute_type" {
  description = "The type of the attribute for DynamoDB table"
  type        = string
}
