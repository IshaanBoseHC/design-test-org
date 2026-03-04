# S3 bucket for application data
resource "aws_s3_bucket" "app_data" {
  bucket = "${var.project_name}-app-data-${var.environment}"

  tags = merge(var.tags, {
    Name        = "app-data-bucket"
    Purpose     = "Application data storage"
  })
}

# Enable versioning (DRIFT FIX: was disabled in cloud)
resource "aws_s3_bucket_versioning" "app_data" {
  bucket = aws_s3_bucket.app_data.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Add server-side encryption (DRIFT FIX: encryption was missing)
resource "aws_s3_bucket_server_side_encryption_configuration" "app_data" {
  bucket = aws_s3_bucket.app_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 bucket for user uploads
resource "aws_s3_bucket" "user_uploads" {
  bucket = "${var.project_name}-user-uploads-${var.environment}"

  tags = merge(var.tags, {
    Name        = "user-uploads-bucket"
    Purpose     = "User uploaded content"
  })
}

# Enable versioning (DRIFT FIX: was disabled in cloud)
resource "aws_s3_bucket_versioning" "user_uploads" {
  bucket = aws_s3_bucket.user_uploads.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Add lifecycle rules (DRIFT FIX: rules were manually configured)
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
    Name        = "app-logs-bucket"
    Purpose     = "Application logging"
  })
}

# Add lifecycle rules for logs (DRIFT FIX: transition was manually configured)
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
