output "logs_bucket_id" {
  description = "The name of the logs bucket"
  value       = aws_s3_bucket.logs.id
}

output "logs_bucket_arn" {
  description = "The ARN of the logs bucket"
  value       = aws_s3_bucket.logs.arn
}

output "backups_bucket_id" {
  description = "The name of the backups bucket"
  value       = aws_s3_bucket.backups.id
}

output "backups_bucket_arn" {
  description = "The ARN of the backups bucket"
  value       = aws_s3_bucket.backups.arn
}

output "assets_bucket_id" {
  description = "The name of the assets bucket"
  value       = var.create_assets_bucket ? aws_s3_bucket.assets[0].id : null
}

output "assets_bucket_arn" {
  description = "The ARN of the assets bucket"
  value       = var.create_assets_bucket ? aws_s3_bucket.assets[0].arn : null
}
