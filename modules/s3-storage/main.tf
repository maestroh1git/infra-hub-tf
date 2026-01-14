# S3 bucket for application logs
resource "aws_s3_bucket" "logs" {
  bucket = "${var.environment}-${var.application}-logs-${var.bucket_suffix}"

  tags = merge(
    {
      Name        = "${var.environment}-${var.application}-logs"
      Environment = var.environment
      Owner       = var.owner
      CostCenter  = var.cost_center
      Application = var.application
      Purpose     = "Application and infrastructure logs"
    },
    var.tags
  )
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_id
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "logs-lifecycle"
    status = "Enabled"

    transition {
      days          = var.logs_transition_to_ia_days
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = var.logs_transition_to_glacier_days
      storage_class = "GLACIER"
    }

    expiration {
      days = var.logs_expiration_days
    }
  }
}

# S3 bucket for backups
resource "aws_s3_bucket" "backups" {
  bucket = "${var.environment}-${var.application}-backups-${var.bucket_suffix}"

  tags = merge(
    {
      Name        = "${var.environment}-${var.application}-backups"
      Environment = var.environment
      Owner       = var.owner
      CostCenter  = var.cost_center
      Application = var.application
      Purpose     = "Database and infrastructure backups"
    },
    var.tags
  )
}

resource "aws_s3_bucket_versioning" "backups" {
  bucket = aws_s3_bucket.backups.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backups" {
  bucket = aws_s3_bucket.backups.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_id
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "backups" {
  bucket = aws_s3_bucket.backups.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "backups" {
  bucket = aws_s3_bucket.backups.id

  rule {
    id     = "backups-lifecycle"
    status = "Enabled"

    transition {
      days          = var.backups_transition_to_ia_days
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = var.backups_transition_to_glacier_days
      storage_class = "GLACIER"
    }

    expiration {
      days = var.backups_expiration_days
    }
  }
}

# S3 bucket for application assets
resource "aws_s3_bucket" "assets" {
  count  = var.create_assets_bucket ? 1 : 0
  bucket = "${var.environment}-${var.application}-assets-${var.bucket_suffix}"

  tags = merge(
    {
      Name        = "${var.environment}-${var.application}-assets"
      Environment = var.environment
      Owner       = var.owner
      CostCenter  = var.cost_center
      Application = var.application
      Purpose     = "Application static assets"
    },
    var.tags
  )
}

resource "aws_s3_bucket_versioning" "assets" {
  count  = var.create_assets_bucket ? 1 : 0
  bucket = aws_s3_bucket.assets[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "assets" {
  count  = var.create_assets_bucket ? 1 : 0
  bucket = aws_s3_bucket.assets[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_id
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "assets" {
  count  = var.create_assets_bucket ? 1 : 0
  bucket = aws_s3_bucket.assets[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
