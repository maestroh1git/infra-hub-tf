output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.state_lock_bucket.bucket
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB table"
  value       = aws_dynamodb_table.state_lock_table.name
}

output "dynamodb_table_arn" {
  description = "The ARN of the DynamoDB table"
  value       = aws_dynamodb_table.state_lock_table.arn
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.state_lock_bucket.arn
}
