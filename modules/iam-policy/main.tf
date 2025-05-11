# Developer IAM Group
resource "aws_iam_group" "developers" {
  name = "${var.project_name}-${var.environment}-developers"
}

# Admin IAM Group
resource "aws_iam_group" "admins" {
  name = "${var.project_name}-${var.environment}-admins"
}

# Read-only IAM Group
resource "aws_iam_group" "readonly" {
  name = "${var.project_name}-${var.environment}-readonly"
}

# Developer policy - limited access
resource "aws_iam_policy" "developer_policy" {
  name        = "${var.project_name}-${var.environment}-developer-policy"
  description = "Policy for developers with limited access to resources"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.project_name}-${var.environment}-*",
          "arn:aws:s3:::${var.project_name}-${var.environment}-*/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          "arn:aws:secretsmanager:*:*:secret:${var.project_name}-${var.environment}-*"
        ]
        Condition = {
          StringEquals = {
            "secretsmanager:ResourceTag/Environment": var.environment
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction",
          "lambda:GetFunction",
          "lambda:ListFunctions"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:GetMetricData",
          "cloudwatch:ListMetrics",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
  
  tags = merge(
    var.common_tags,
    var.tags,
    {
      Owner        = var.owner
      Environment  = var.environment
      CostCenter   = var.cost_center
      Application  = var.application
    }
  )
}

# Admin policy - full access to project resources
resource "aws_iam_policy" "admin_policy" {
  name        = "${var.project_name}-${var.environment}-admin-policy"
  description = "Policy for administrators with full access to project resources"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
        Condition = {
          StringLike = {
            "aws:ResourceTag/Project": var.project_name
          }
        }
      }
    ]
  })
  
  tags = merge(
    var.common_tags,
    var.tags,
    {
      Owner        = var.owner
      Environment  = var.environment
      CostCenter   = var.cost_center
      Application  = var.application
    }
  )
}

# Attach developer policy to developer group
resource "aws_iam_group_policy_attachment" "developer_policy_attachment" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.developer_policy.arn
}

# Attach admin policy to admin group
resource "aws_iam_group_policy_attachment" "admin_policy_attachment" {
  group      = aws_iam_group.admins.name
  policy_arn = aws_iam_policy.admin_policy.arn
}

# Attach AWS managed read-only policy to readonly group
resource "aws_iam_group_policy_attachment" "readonly_policy_attachment" {
  group      = aws_iam_group.readonly.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# Role for EC2 instances
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-${var.environment}-ec2-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  
  tags = merge(
    var.common_tags,
    var.tags,
    {
      Owner        = var.owner
      Environment  = var.environment
      CostCenter   = var.cost_center
      Application  = var.application
    }
  )
}

# Policy for EC2 to access S3, Secrets Manager, etc.
resource "aws_iam_policy" "ec2_policy" {
  name        = "${var.project_name}-${var.environment}-ec2-policy"
  description = "Policy for EC2 instances to access required resources"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.project_name}-${var.environment}-*",
          "arn:aws:s3:::${var.project_name}-${var.environment}-*/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          "arn:aws:secretsmanager:*:*:secret:${var.project_name}-${var.environment}-*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
  
  tags = merge(
    var.common_tags,
    var.tags,
    {
      Owner        = var.owner
      Environment  = var.environment
      CostCenter   = var.cost_center
      Application  = var.application
    }
  )
}

# Attach EC2 policy to EC2 role
resource "aws_iam_role_policy_attachment" "ec2_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}

# Role for Lambda functions
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-${var.environment}-lambda-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  
  tags = merge(
    var.common_tags,
    var.tags,
    {
      Owner        = var.owner
      Environment  = var.environment
      CostCenter   = var.cost_center
      Application  = var.application
    }
  )
}

# Policy for Lambda to access S3, Secrets Manager, etc.
resource "aws_iam_policy" "lambda_policy" {
  name        = "${var.project_name}-${var.environment}-lambda-policy"
  description = "Policy for Lambda functions to access required resources"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.project_name}-${var.environment}-*",
          "arn:aws:s3:::${var.project_name}-${var.environment}-*/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          "arn:aws:secretsmanager:*:*:secret:${var.project_name}-${var.environment}-*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ]
        Resource = "*"
      }
    ]
  })
  
  tags = merge(
    var.common_tags,
    var.tags,
    {
      Owner        = var.owner
      Environment  = var.environment
      CostCenter   = var.cost_center
      Application  = var.application
    }
  )
}

# Attach Lambda policy to Lambda role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Create Instance Profile for EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-${var.environment}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# Role for ALB logging
resource "aws_iam_role" "alb_role" {
  name = "${var.project_name}-${var.environment}-alb-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "elasticloadbalancing.amazonaws.com"
        }
      }
    ]
  })
  
  tags = merge(
    var.common_tags,
    var.tags,
    {
      Owner        = var.owner
      Environment  = var.environment
      CostCenter   = var.cost_center
      Application  = var.application
    }
  )
}

# Policy for ALB logging
resource "aws_iam_policy" "alb_policy" {
  name        = "${var.project_name}-${var.environment}-alb-policy"
  description = "Policy for ALB logging"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        Resource = [
          "arn:aws:logs:*:*:*"
        ]
      }
    ]
  })
  
  tags = merge(
    var.common_tags,
    var.tags,
    {
      Owner        = var.owner
      Environment  = var.environment
      CostCenter   = var.cost_center
      Application  = var.application
    }
  )
}

# Attach ALB policy to ALB role
resource "aws_iam_role_policy_attachment" "alb_policy_attachment" {
  role       = aws_iam_role.alb_role.name
  policy_arn = aws_iam_policy.alb_policy.arn
}