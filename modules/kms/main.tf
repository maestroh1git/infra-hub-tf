resource "aws_kms_key" "main" {
  description             = "${var.environment}-${var.application}-kms-key"
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation
  multi_region            = var.multi_region

  tags = merge(
    {
      Name        = "${var.environment}-${var.application}-kms-key"
      Environment = var.environment
      Owner       = var.owner
      CostCenter  = var.cost_center
      Application = var.application
    },
    var.tags
  )
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.environment}-${var.application}"
  target_key_id = aws_kms_key.main.key_id
}
