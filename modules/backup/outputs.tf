output "backup_vault_id" {
  description = "The ID of the backup vault"
  value       = aws_backup_vault.main.id
}

output "backup_vault_arn" {
  description = "The ARN of the backup vault"
  value       = aws_backup_vault.main.arn
}

output "backup_plan_id" {
  description = "The ID of the backup plan"
  value       = aws_backup_plan.main.id
}

output "backup_plan_arn" {
  description = "The ARN of the backup plan"
  value       = aws_backup_plan.main.arn
}

output "backup_iam_role_arn" {
  description = "The ARN of the IAM role for backups"
  value       = aws_iam_role.backup.arn
}

output "sns_topic_arn" {
  description = "The ARN of the SNS topic for backup notifications"
  value       = var.enable_notifications ? aws_sns_topic.backup_notifications[0].arn : null
}
