# S3 bucket for application data
resource "aws_s3_bucket" "app_data" {
  bucket = "${var.project_name}-app-data-${var.environment}"

  tags = merge(var.tags, {
    Name    = "app-data-bucket"
    Purpose = "Application data storage"
  })
}

# S3 bucket for user uploads
resource "aws_s3_bucket" "user_uploads" {
  bucket = "${var.project_name}-user-uploads-${var.environment}"

  tags = merge(var.tags, {
    Name    = "user-uploads-bucket"
    Purpose = "User uploaded content"
  })
}

# S3 bucket for application logs
resource "aws_s3_bucket" "app_logs" {
  bucket = "${var.project_name}-app-logs-${var.environment}"

  tags = merge(var.tags, {
    Name    = "app-logs-bucket"
    Purpose = "Application logging"
  })
}
