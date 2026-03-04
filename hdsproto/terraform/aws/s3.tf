# S3 bucket for application data
resource "aws_s3_bucket" "app_data" {
  bucket = "${var.project_name}-app-data-${var.environment}"

  tags = merge(var.tags, {
    Name           = "app-data-bucket"
    Purpose        = "Application data storage"
    SecurityLevel  = "high"           # SECURITY: Added compliance tag
    DataClassification = "sensitive"  # SECURITY: Added classification
  })
}

# Enable versioning
resource "aws_s3_bucket_versioning" "app_data" {
  bucket = aws_s3_bucket.app_data.id

  versioning_configuration {
    status = "Enabled"
  }
}

# SECURITY: Upgrade to KMS encryption with customer-managed key
resource "aws_s3_bucket_server_side_encryption_configuration" "app_data" {
  bucket = aws_s3_bucket.app_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_encryption.arn
    }
    bucket_key_enabled = true
  }
}

# SECURITY: Block public access
resource "aws_s3_bucket_public_access_block" "app_data" {
  bucket = aws_s3_bucket.app_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 bucket for user uploads
resource "aws_s3_bucket" "user_uploads" {
  bucket = "${var.project_name}-user-uploads-${var.environment}"

  tags = merge(var.tags, {
    Name           = "user-uploads-bucket"
    Purpose        = "User uploaded content"
    SecurityLevel  = "medium"         # SECURITY: Added compliance tag
    DataClassification = "public"     # SECURITY: Added classification
  })
}

# Enable versioning
resource "aws_s3_bucket_versioning" "user_uploads" {
  bucket = aws_s3_bucket.user_uploads.id

  versioning_configuration {
    status = "Enabled"
  }
}

# SECURITY: Add encryption for user uploads
resource "aws_s3_bucket_server_side_encryption_configuration" "user_uploads" {
  bucket = aws_s3_bucket.user_uploads.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_encryption.arn
    }
    bucket_key_enabled = true
  }
}

# SECURITY: Block public access
resource "aws_s3_bucket_public_access_block" "user_uploads" {
  bucket = aws_s3_bucket.user_uploads.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Add lifecycle rules
resource "aws_s3_bucket_lifecycle_configuration" "user_uploads" {
  bucket = aws_s3_bucket.user_uploads.id

  rule {
    id     = "expire-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

# S3 bucket for application logs
resource "aws_s3_bucket" "app_logs" {
  bucket = "${var.project_name}-app-logs-${var.environment}"

  tags = merge(var.tags, {
    Name           = "app-logs-bucket"
    Purpose        = "Application logging"
    SecurityLevel  = "high"           # SECURITY: Added compliance tag
    DataClassification = "internal"   # SECURITY: Added classification
  })
}

# SECURITY: Add encryption for logs
resource "aws_s3_bucket_server_side_encryption_configuration" "app_logs" {
  bucket = aws_s3_bucket.app_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_encryption.arn
    }
    bucket_key_enabled = true
  }
}

# SECURITY: Block public access
resource "aws_s3_bucket_public_access_block" "app_logs" {
  bucket = aws_s3_bucket.app_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Add lifecycle rules for logs
resource "aws_s3_bucket_lifecycle_configuration" "app_logs" {
  bucket = aws_s3_bucket.app_logs.id

  rule {
    id     = "transition-to-glacier"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}
