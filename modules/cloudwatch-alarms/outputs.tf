output "sns_topic_arn" {
  description = "The ARN of the SNS topic for alarms"
  value       = aws_sns_topic.alarms.arn
}

output "sns_topic_name" {
  description = "The name of the SNS topic for alarms"
  value       = aws_sns_topic.alarms.name
}

output "ec2_cpu_alarm_ids" {
  description = "IDs of EC2 CPU alarms"
  value       = var.enable_ec2_alarms ? aws_cloudwatch_metric_alarm.ec2_cpu[*].id : []
}

output "rds_cpu_alarm_id" {
  description = "ID of RDS CPU alarm"
  value       = var.enable_rds_alarms && var.rds_instance_id != "" ? aws_cloudwatch_metric_alarm.rds_cpu[0].id : null
}

output "alb_response_time_alarm_id" {
  description = "ID of ALB response time alarm"
  value       = var.enable_alb_alarms && var.alb_arn_suffix != "" ? aws_cloudwatch_metric_alarm.alb_target_response_time[0].id : null
}
