# IAM role for application service
resource "aws_iam_role" "app_service" {
  name = "${var.project_name}-app-service-role"

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

  tags = var.tags
}

# IAM policy for S3 access (DRIFT FIX: added missing actions)
resource "aws_iam_policy" "s3_access" {
  name        = "${var.project_name}-s3-access"
  description = "Allow access to application S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",      # DRIFT FIX: was missing but in use
          "s3:ListBucket"         # DRIFT FIX: was missing but in use
        ]
        Resource = [
          "${aws_s3_bucket.app_data.arn}/*",
          "${aws_s3_bucket.user_uploads.arn}/*",
          aws_s3_bucket.app_data.arn,          # DRIFT FIX: for ListBucket
          aws_s3_bucket.user_uploads.arn       # DRIFT FIX: for ListBucket
        ]
      },
      {
        # DRIFT FIX: CloudWatch Logs permission was in use but not in code
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:*:log-group:/aws/${var.project_name}/*"
      }
    ]
  })

  tags = var.tags
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "app_s3_access" {
  role       = aws_iam_role.app_service.name
  policy_arn = aws_iam_policy.s3_access.arn
}
