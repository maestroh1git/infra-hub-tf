# AWS Backup Vault
resource "aws_backup_vault" "main" {
  name        = "${var.environment}-${var.application}-backup-vault"
  kms_key_arn = var.kms_key_arn

  tags = merge(
    {
      Name        = "${var.environment}-${var.application}-backup-vault"
      Environment = var.environment
      Owner       = var.owner
      CostCenter  = var.cost_center
      Application = var.application
    },
    var.tags
  )
}

# AWS Backup Plan
resource "aws_backup_plan" "main" {
  name = "${var.environment}-${var.application}-backup-plan"

  rule {
    rule_name         = "daily_backups"
    target_vault_name = aws_backup_vault.main.name
    schedule          = var.backup_schedule

    lifecycle {
      delete_after       = var.backup_retention_days
      cold_storage_after = var.cold_storage_after_days
    }

    recovery_point_tags = merge(
      {
        Environment = var.environment
        Application = var.application
        BackupType  = "Automated"
      },
      var.tags
    )
  }

  advanced_backup_setting {
    backup_options = {
      WindowsVSS = "enabled"
    }
    resource_type = "EC2"
  }

  tags = merge(
    {
      Name        = "${var.environment}-${var.application}-backup-plan"
      Environment = var.environment
      Owner       = var.owner
      CostCenter  = var.cost_center
      Application = var.application
    },
    var.tags
  )
}

# IAM role for AWS Backup
resource "aws_iam_role" "backup" {
  name = "${var.environment}-${var.application}-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    {
      Name        = "${var.environment}-${var.application}-backup-role"
      Environment = var.environment
      Owner       = var.owner
      CostCenter  = var.cost_center
      Application = var.application
    },
    var.tags
  )
}

# Attach AWS managed backup policy
resource "aws_iam_role_policy_attachment" "backup" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "restore" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

# Backup selection
resource "aws_backup_selection" "main" {
  name         = "${var.environment}-${var.application}-backup-selection"
  iam_role_arn = aws_iam_role.backup.arn
  plan_id      = aws_backup_plan.main.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Backup"
    value = "true"
  }

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Environment"
    value = var.environment
  }
}

# SNS topic for backup notifications
resource "aws_sns_topic" "backup_notifications" {
  count = var.enable_notifications ? 1 : 0
  name  = "${var.environment}-${var.application}-backup-notifications"

  tags = merge(
    {
      Name        = "${var.environment}-${var.application}-backup-notifications"
      Environment = var.environment
      Owner       = var.owner
      CostCenter  = var.cost_center
      Application = var.application
    },
    var.tags
  )
}

resource "aws_backup_vault_notifications" "main" {
  count               = var.enable_notifications ? 1 : 0
  backup_vault_name   = aws_backup_vault.main.name
  sns_topic_arn       = aws_sns_topic.backup_notifications[0].arn
  backup_vault_events = ["BACKUP_JOB_COMPLETED", "BACKUP_JOB_FAILED", "RESTORE_JOB_COMPLETED", "RESTORE_JOB_FAILED"]
}
