# KMS key for S3 bucket encryption
resource "aws_kms_key" "s3_encryption" {
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = merge(var.tags, {
    Name    = "s3-encryption-key"
    Purpose = "S3 bucket encryption"
  })
}

# KMS key alias
resource "aws_kms_alias" "s3_encryption" {
  name          = "alias/${var.project_name}-s3-encryption"
  target_key_id = aws_kms_key.s3_encryption.key_id
}

# KMS key policy
resource "aws_kms_key_policy" "s3_encryption" {
  key_id = aws_kms_key.s3_encryption.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::*:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow S3 to use the key"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      }
    ]
  })
}
