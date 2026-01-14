# SNS Topic for alarm notifications
resource "aws_sns_topic" "alarms" {
  name = "${var.environment}-${var.application}-alarms"

  tags = merge(
    {
      Name        = "${var.environment}-${var.application}-alarms"
      Environment = var.environment
      Owner       = var.owner
      CostCenter  = var.cost_center
      Application = var.application
    },
    var.tags
  )
}

resource "aws_sns_topic_subscription" "alarm_email" {
  count     = var.alarm_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

# EC2 CPU Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
  count               = var.enable_ec2_alarms && length(var.ec2_instance_ids) > 0 ? length(var.ec2_instance_ids) : 0
  alarm_name          = "${var.environment}-${var.application}-ec2-cpu-${count.index}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = var.ec2_cpu_threshold
  alarm_description   = "This metric monitors EC2 CPU utilization"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  dimensions = {
    InstanceId = var.ec2_instance_ids[count.index]
  }

  tags = merge(
    {
      Name        = "${var.environment}-${var.application}-ec2-cpu-alarm"
      Environment = var.environment
    },
    var.tags
  )
}

# RDS CPU Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  count               = var.enable_rds_alarms && var.rds_instance_id != "" ? 1 : 0
  alarm_name          = "${var.environment}-${var.application}-rds-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.rds_cpu_threshold
  alarm_description   = "This metric monitors RDS CPU utilization"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }

  tags = merge(
    {
      Name        = "${var.environment}-${var.application}-rds-cpu-alarm"
      Environment = var.environment
    },
    var.tags
  )
}

# RDS Free Storage Space Alarm
resource "aws_cloudwatch_metric_alarm" "rds_storage" {
  count               = var.enable_rds_alarms && var.rds_instance_id != "" ? 1 : 0
  alarm_name          = "${var.environment}-${var.application}-rds-storage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.rds_storage_threshold
  alarm_description   = "This metric monitors RDS free storage space"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }

  tags = merge(
    {
      Name        = "${var.environment}-${var.application}-rds-storage-alarm"
      Environment = var.environment
    },
    var.tags
  )
}

# RDS Database Connections Alarm
resource "aws_cloudwatch_metric_alarm" "rds_connections" {
  count               = var.enable_rds_alarms && var.rds_instance_id != "" ? 1 : 0
  alarm_name          = "${var.environment}-${var.application}-rds-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.rds_connections_threshold
  alarm_description   = "This metric monitors RDS database connections"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }

  tags = merge(
    {
      Name        = "${var.environment}-${var.application}-rds-connections-alarm"
      Environment = var.environment
    },
    var.tags
  )
}

# ALB Target Response Time Alarm
resource "aws_cloudwatch_metric_alarm" "alb_target_response_time" {
  count               = var.enable_alb_alarms && var.alb_arn_suffix != "" ? 1 : 0
  alarm_name          = "${var.environment}-${var.application}-alb-response-time"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Average"
  threshold           = var.alb_response_time_threshold
  alarm_description   = "This metric monitors ALB target response time"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  tags = merge(
    {
      Name        = "${var.environment}-${var.application}-alb-response-alarm"
      Environment = var.environment
    },
    var.tags
  )
}

# ALB Unhealthy Host Count Alarm
resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts" {
  count               = var.enable_alb_alarms && var.target_group_arn_suffix != "" ? 1 : 0
  alarm_name          = "${var.environment}-${var.application}-alb-unhealthy-hosts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Average"
  threshold           = var.unhealthy_host_threshold
  alarm_description   = "This metric monitors unhealthy hosts behind ALB"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  dimensions = {
    TargetGroup  = var.target_group_arn_suffix
    LoadBalancer = var.alb_arn_suffix
  }

  tags = merge(
    {
      Name        = "${var.environment}-${var.application}-alb-unhealthy-alarm"
      Environment = var.environment
    },
    var.tags
  )
}

# EKS Cluster CPU Alarm (for nodes)
resource "aws_cloudwatch_metric_alarm" "eks_node_cpu" {
  count               = var.enable_eks_alarms && var.eks_cluster_name != "" ? 1 : 0
  alarm_name          = "${var.environment}-${var.application}-eks-node-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "node_cpu_utilization"
  namespace           = "ContainerInsights"
  period              = "300"
  statistic           = "Average"
  threshold           = var.eks_cpu_threshold
  alarm_description   = "This metric monitors EKS node CPU utilization"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  dimensions = {
    ClusterName = var.eks_cluster_name
  }

  tags = merge(
    {
      Name        = "${var.environment}-${var.application}-eks-cpu-alarm"
      Environment = var.environment
    },
    var.tags
  )
}
