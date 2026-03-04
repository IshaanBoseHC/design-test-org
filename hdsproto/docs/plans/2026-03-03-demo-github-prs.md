# Demo GitHub PRs Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create two realistic demo GitHub pull requests showcasing Terraform drift reconciliation and security hardening for the HDS prototype.

**Architecture:** Two feature branches with realistic Terraform AWS infrastructure files. Each branch shows specific changes (drift fixes vs. security hardening) with detailed PR descriptions following the GitHub wireframe format. All infrastructure isolated in `terraform/` directory with no impact on Ember app.

**Tech Stack:** Terraform (AWS provider), Git, GitHub CLI (`gh`), Markdown

---

## Task 1: Setup Demo Infrastructure Directory

**Files:**
- Create: `terraform/README.md`
- Modify: `.gitignore`

**Step 1: Create terraform directory**

Run: `mkdir -p terraform/aws`
Expected: Directories created

**Step 2: Create demo warning README**

Create file at `terraform/README.md`:

```markdown
# Demo Infrastructure

⚠️ **WARNING: DEMO FILES ONLY - DO NOT APPLY** ⚠️

These Terraform configurations are for demonstration purposes only. They showcase:
- Drift detection and reconciliation scenarios
- Security hardening workflows
- Automated remediation patterns

**Do not run `terraform apply` on these files.** They reference fictional AWS resources for demo PRs.

## Purpose

These files support two demo pull requests:
1. `fix/drift-reconciliation` - Shows drift detection corrections
2. `security/hardening-controls` - Shows security vulnerability fixes

## Repository Structure

```
terraform/
├── aws/
│   ├── s3.tf              # S3 bucket configurations
│   ├── iam.tf             # IAM policies and roles
│   ├── security_groups.tf # Security group rules
│   ├── kms.tf             # KMS encryption keys
│   └── variables.tf       # Configuration variables
└── README.md              # This file
```
```

**Step 3: Update .gitignore**

Add to `.gitignore`:

```gitignore
# Terraform
terraform/.terraform/
terraform/**/.terraform/
terraform/**/*.tfstate
terraform/**/*.tfstate.*
terraform/**/*.tfplan
terraform/**/.terraform.lock.hcl
```

**Step 4: Commit setup**

```bash
git add terraform/README.md .gitignore
git commit -m "chore: add demo terraform infrastructure directory

- Add terraform/ directory for demo PRs
- Add README warning about demo-only files
- Update .gitignore for Terraform state files

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

Expected: Commit created successfully

---

## Task 2: Create Baseline Terraform Files

**Files:**
- Create: `terraform/aws/variables.tf`
- Create: `terraform/aws/s3.tf`
- Create: `terraform/aws/iam.tf`
- Create: `terraform/aws/security_groups.tf`
- Create: `terraform/aws/kms.tf`

**Step 1: Create variables file**

Create `terraform/aws/variables.tf`:

```hcl
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "demo"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "terraform-remediation"
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-west-2"
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Environment = "demo"
    ManagedBy   = "terraform"
    Project     = "remediation-prototype"
  }
}
```

**Step 2: Create S3 configuration (baseline - before fixes)**

Create `terraform/aws/s3.tf`:

```hcl
# S3 bucket for application data
resource "aws_s3_bucket" "app_data" {
  bucket = "${var.project_name}-app-data-${var.environment}"

  tags = merge(var.tags, {
    Name        = "app-data-bucket"
    Purpose     = "Application data storage"
  })
}

# S3 bucket for user uploads
resource "aws_s3_bucket" "user_uploads" {
  bucket = "${var.project_name}-user-uploads-${var.environment}"

  tags = merge(var.tags, {
    Name        = "user-uploads-bucket"
    Purpose     = "User uploaded content"
  })
}

# S3 bucket for application logs
resource "aws_s3_bucket" "app_logs" {
  bucket = "${var.project_name}-app-logs-${var.environment}"

  tags = merge(var.tags, {
    Name        = "app-logs-bucket"
    Purpose     = "Application logging"
  })
}
```

**Step 3: Create IAM configuration (baseline)**

Create `terraform/aws/iam.tf`:

```hcl
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

# IAM policy for S3 access
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
          "s3:PutObject"
        ]
        Resource = [
          "${aws_s3_bucket.app_data.arn}/*",
          "${aws_s3_bucket.user_uploads.arn}/*"
        ]
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
```

**Step 4: Create security groups configuration (baseline)**

Create `terraform/aws/security_groups.tf`:

```hcl
# Security group for web application
resource "aws_security_group" "web_app" {
  name        = "${var.project_name}-web-app"
  description = "Security group for web application servers"

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "web-app-sg"
  })
}

# Security group for database
resource "aws_security_group" "database" {
  name        = "${var.project_name}-database"
  description = "Security group for database servers"

  ingress {
    description = "PostgreSQL from anywhere"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "database-sg"
  })
}
```

**Step 5: Create KMS configuration (baseline - minimal)**

Create `terraform/aws/kms.tf`:

```hcl
# Placeholder - KMS keys will be added in security hardening PR
```

**Step 6: Commit baseline files**

```bash
git add terraform/aws/
git commit -m "feat: add baseline terraform AWS infrastructure

- Add variables configuration
- Add S3 bucket definitions
- Add IAM role and policies
- Add security groups
- Add KMS placeholder

These are demo files for PR examples.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

Expected: Commit created with 5 new files

**Step 7: Push baseline to master**

```bash
git push origin master
```

Expected: Changes pushed successfully

---

## Task 3: Create Drift Reconciliation PR

**Files:**
- Modify: `terraform/aws/s3.tf`
- Modify: `terraform/aws/iam.tf`
- Create: `.github/pr-descriptions/drift-pr.md`

**Step 1: Create feature branch**

```bash
git checkout -b fix/drift-reconciliation
```

Expected: Switched to new branch

**Step 2: Modify S3 configuration to show drift fixes**

Update `terraform/aws/s3.tf` - add versioning and encryption that was "missing":

```hcl
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
```

**Step 3: Modify IAM policy to reflect actual permissions**

Update `terraform/aws/iam.tf` - add missing permissions:

```hcl
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
```

**Step 4: Create PR description file**

Create `.github/pr-descriptions/drift-pr.md`:

```markdown
**Generated by:** terraform-agent-a7f3b2c4
**Labels:** drift-detection, automated-fix, terraform

---

## What was corrected

This PR reconciles Terraform configuration with the actual cloud state. The following drift was detected and corrected:

- **S3 Bucket Versioning**: `app-data` and `user-uploads` buckets had versioning enabled in AWS but not in Terraform configuration
- **S3 Encryption**: `app-data` bucket had server-side encryption enabled manually but was missing from code
- **S3 Lifecycle Rules**: Multiple buckets had lifecycle policies configured manually in the AWS console
- **IAM Permissions**: Application role was using `s3:DeleteObject` and `s3:ListBucket` permissions not defined in policy
- **CloudWatch Logs**: IAM policy was missing CloudWatch Logs permissions that are actively in use by the application

## Why this change was made

A drift detection scan identified 8 configuration discrepancies between Terraform state and actual AWS resources. These changes ensure that:

1. **Infrastructure as Code accuracy** - Terraform reflects the true state of production resources
2. **Prevent configuration loss** - Manual changes are now tracked and version-controlled
3. **Enable safe updates** - Future Terraform applies won't accidentally remove working configurations
4. **Audit compliance** - All infrastructure changes are documented in version control

The drift likely occurred due to:
- Manual configuration adjustments during incident response
- Console-based troubleshooting that wasn't backported to code
- Permissions added directly via AWS IAM during feature development

## Drift Analysis

### Impact Assessment

- **Risk Level**: Medium
- **Resources Affected**: 5 (3 S3 buckets, 1 IAM policy, 1 IAM role)
- **Breaking Changes**: None - only adding missing configurations
- **Rollback Plan**: Standard `terraform apply` rollback available

### Technical Details

**S3 Versioning Drift:**
- Detected: Versioning enabled on `app-data-bucket` and `user-uploads-bucket` in AWS
- Root Cause: Enabled manually during data recovery testing
- Fix: Added `aws_s3_bucket_versioning` resources to match actual state

**IAM Permission Drift:**
- Detected: IAM policy allows actions (`DeleteObject`, `ListBucket`, `logs:*`) not in Terraform
- Root Cause: Permissions added during feature development without Terraform update
- Fix: Updated policy JSON to include all permissions currently in use
- Security Review: All added permissions are least-privilege for current application needs

**Lifecycle Policy Drift:**
- Detected: S3 lifecycle rules configured in console but not in code
- Root Cause: Cost optimization implemented manually
- Fix: Added `aws_s3_bucket_lifecycle_configuration` resources

## Remediation Checklist

| Resource | Issue Found | Remediation Applied | Status |
|----------|-------------|---------------------|--------|
| `app-data` S3 bucket | Versioning enabled in AWS but not in Terraform | Added `aws_s3_bucket_versioning` resource | ✅ Complete |
| `app-data` S3 bucket | Server-side encryption configured manually | Added encryption configuration block | ✅ Complete |
| `user-uploads` S3 bucket | Versioning enabled in AWS but not in Terraform | Added `aws_s3_bucket_versioning` resource | ✅ Complete |
| `user-uploads` S3 bucket | Lifecycle rules configured manually | Added lifecycle configuration block | ✅ Complete |
| `app-logs` S3 bucket | Glacier transition rule configured manually | Added lifecycle configuration with transitions | ✅ Complete |
| `s3-access` IAM policy | `DeleteObject` permission in use but not in policy | Added `s3:DeleteObject` action | ✅ Complete |
| `s3-access` IAM policy | `ListBucket` permission in use but not in policy | Added `s3:ListBucket` action with bucket ARNs | ✅ Complete |
| `s3-access` IAM policy | CloudWatch Logs permissions missing | Added `logs:*` permissions for application logging | ✅ Complete |

## Testing & Validation

- ✅ `terraform plan` executed successfully - 12 resources to add, 0 to change, 0 to destroy
- ✅ No breaking changes detected - all additions are non-disruptive
- ✅ State refresh shows all configurations match actual cloud resources
- ✅ IAM policy validation passed - no overly permissive rules introduced
- ✅ All resources pass `tflint` security checks

### Terraform Plan Summary

```
Plan: 12 to add, 0 to change, 0 to destroy.

Changes:
  + aws_s3_bucket_versioning.app_data
  + aws_s3_bucket_versioning.user_uploads
  + aws_s3_bucket_server_side_encryption_configuration.app_data
  + aws_s3_bucket_lifecycle_configuration.user_uploads
  + aws_s3_bucket_lifecycle_configuration.app_logs
  ~ aws_iam_policy.s3_access (policy updated)
```

## Additional Context

- **Drift Detection Tool**: HCP Terraform Continuous Drift Detection
- **Detection Time**: 2026-03-02 14:23:17 UTC
- **Affected Workspace**: `terraform-remediation-demo`
- **Terraform Version**: 1.7.0
- **AWS Provider Version**: 5.38.0

### Related Documentation
- [AWS S3 Versioning Best Practices](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Versioning.html)
- [Terraform AWS S3 Bucket Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)
- [IAM Policy Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)

---

**Review Notes:**
- All changes reconcile actual cloud state with Terraform configuration
- No destructive operations - only additions and policy updates
- Manual review of IAM permissions confirmed least-privilege compliance
- Recommended action: Approve and merge to prevent future drift
```

**Step 5: Commit drift fixes**

```bash
mkdir -p .github/pr-descriptions
git add terraform/aws/s3.tf terraform/aws/iam.tf .github/pr-descriptions/drift-pr.md
git commit -m "fix(drift): reconcile state and configuration for affected resources

Detected Configuration Drift:
- S3 bucket versioning enabled in AWS but not in Terraform
- Server-side encryption configured manually on app-data bucket
- Lifecycle rules configured via console on multiple buckets
- IAM policy missing permissions actively in use (DeleteObject, ListBucket, CloudWatch Logs)

Changes Made:
- Add aws_s3_bucket_versioning resources for app-data and user-uploads
- Add server-side encryption configuration for app-data bucket
- Add lifecycle configuration for user-uploads and app-logs buckets
- Update IAM policy to include all permissions currently in use
- Add CloudWatch Logs permissions to IAM policy

Impact: 12 resources to add, 0 to change, 0 to destroy
Risk: Low - Only additive changes, no destructive operations

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

Expected: Commit created with changes to 3 files

**Step 6: Push branch**

```bash
git push origin fix/drift-reconciliation
```

Expected: Branch pushed to GitHub

**Step 7: Create PR using GitHub CLI**

```bash
gh pr create \
  --base master \
  --head fix/drift-reconciliation \
  --title "fix(drift): reconcile state and configuration for affected resources" \
  --body-file .github/pr-descriptions/drift-pr.md \
  --label "drift-detection,automated-fix,terraform"
```

Expected: PR created successfully with number

**Step 8: Verify PR**

```bash
gh pr view --web
```

Expected: Browser opens showing PR with formatted description

---

## Task 4: Create Security Hardening PR

**Files:**
- Modify: `terraform/aws/security_groups.tf`
- Modify: `terraform/aws/kms.tf`
- Modify: `terraform/aws/s3.tf`
- Create: `.github/pr-descriptions/security-pr.md`

**Step 1: Return to master and create security branch**

```bash
git checkout master
git checkout -b security/hardening-controls
```

Expected: Switched to new branch from master

**Step 2: Add KMS encryption keys**

Replace `terraform/aws/kms.tf` content:

```hcl
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
```

**Step 3: Update S3 to use KMS encryption**

Update `terraform/aws/s3.tf` - change encryption from AES256 to KMS:

```hcl
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
```

**Step 4: Harden security groups**

Update `terraform/aws/security_groups.tf` - restrict overly permissive rules:

```hcl
# SECURITY: Define allowed IP ranges for management access
variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the application"
  type        = list(string)
  default = [
    "10.0.0.0/8",      # Internal network
    "172.16.0.0/12",   # Internal network
    "192.168.0.0/16"   # Internal network
  ]
}

# Security group for web application
resource "aws_security_group" "web_app" {
  name        = "${var.project_name}-web-app"
  description = "Security group for web application servers"

  # SECURITY: Keep HTTPS from anywhere (required for public web)
  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SECURITY: Keep HTTP from anywhere (redirect to HTTPS)
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name          = "web-app-sg"
    SecurityLevel = "medium"
  })
}

# SECURITY: Hardened database security group
resource "aws_security_group" "database" {
  name        = "${var.project_name}-database"
  description = "Security group for database servers"

  # SECURITY: Restrict to internal networks only (was 0.0.0.0/0)
  ingress {
    description = "PostgreSQL from internal networks only"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  # SECURITY: Restrict egress to only what's needed
  egress {
    description = "HTTPS for updates"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name          = "database-sg"
    SecurityLevel = "high"
  })
}

# SECURITY: New security group for application internal communication
resource "aws_security_group" "app_internal" {
  name        = "${var.project_name}-app-internal"
  description = "Security group for internal app-to-app communication"

  ingress {
    description     = "Allow from web app"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web_app.id]
  }

  egress {
    description = "Allow to database"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.database.id]
  }

  tags = merge(var.tags, {
    Name          = "app-internal-sg"
    SecurityLevel = "high"
  })
}
```

**Step 5: Create security PR description**

Create `.github/pr-descriptions/security-pr.md`:

```markdown
**Generated by:** terraform-agent-d8e1c5f9
**Labels:** security, hardening, terraform, compliance

---

## What was secured

This PR implements critical security controls identified by our security scanning tools. The following vulnerabilities and misconfigurations have been remediated:

- **KMS Encryption**: Upgraded all S3 buckets from AWS-managed (SSE-S3) to customer-managed KMS encryption
- **Public Access**: Blocked all public access to S3 buckets at the bucket level
- **Security Group Hardening**: Removed overly permissive `0.0.0.0/0` rules from database security group
- **Network Segmentation**: Added new security group for internal app communication with least-privilege rules
- **Compliance Tagging**: Added `SecurityLevel` and `DataClassification` tags for compliance tracking
- **Key Rotation**: Enabled automatic key rotation on KMS keys

## Why this change was made

A security audit identified multiple CIS AWS Foundations Benchmark violations and NIST 800-53 control gaps. These changes address:

### Critical Findings
- **CIS 2.1.1**: S3 buckets were not using customer-managed KMS keys (Risk: High)
- **CIS 2.1.5**: S3 buckets lacked public access blocks (Risk: High)
- **CIS 5.2**: Database security group allowed access from `0.0.0.0/0` (Risk: Critical)

### Compliance Requirements
- **NIST SC-13**: Cryptographic protection using FIPS 140-2 validated modules
- **NIST SC-28**: Protection of data at rest using encryption
- **NIST AC-4**: Information flow enforcement through network segmentation

### Business Impact
- **Data Protection**: Customer data now encrypted with keys under our control
- **Audit Readiness**: Security controls documented and enforced via IaC
- **Incident Response**: Key rotation and access logging enabled for forensics
- **Compliance**: Meets SOC 2, ISO 27001, and HIPAA encryption requirements

## Security Remediation

### Encryption at Rest (CIS 2.1.1)

**Previous State:**
- S3 buckets used AWS-managed encryption (SSE-S3)
- No customer control over encryption keys
- No key rotation policy
- No encryption key access logging

**New State:**
- All buckets use customer-managed KMS keys
- Automatic key rotation enabled (365-day cycle)
- CloudTrail logging for all key usage
- Separate key policies for access control

**Impact:** Prevents AWS from accessing encryption keys without explicit permission. Enables key revocation in breach scenarios.

### Public Access Controls (CIS 2.1.5)

**Previous State:**
- S3 buckets relied on ACLs and bucket policies for access control
- No account-level public access blocks
- Risk of misconfiguration exposing data

**New State:**
- Four-layer public access block enabled on all buckets:
  - `block_public_acls = true`
  - `block_public_policy = true`
  - `ignore_public_acls = true`
  - `restrict_public_buckets = true`

**Impact:** Defense-in-depth protection. Even if ACL or policy is misconfigured, public access is blocked.

### Network Hardening (CIS 5.2)

**Previous State:**
- Database security group allowed PostgreSQL (5432) from `0.0.0.0/0`
- Any internet host could attempt database connection
- Risk: Brute force attacks, credential stuffing, data exfiltration

**New State:**
- Database access restricted to internal CIDR blocks only
- New `app_internal` security group for app-to-database communication
- Security group references instead of CIDR blocks where possible
- Egress limited to HTTPS only (for updates)

**Impact:** Eliminates external attack surface. Database only accessible from application tier.

### Compliance Tagging

Added required tags for automated compliance scanning:
- `SecurityLevel`: high/medium/low classification
- `DataClassification`: sensitive/internal/public designation
- Enables automated policy enforcement via AWS Config rules

## Remediation Checklist

| Resource | Vulnerability Found | Remediation Applied | Status | CVE/CIS |
|----------|---------------------|---------------------|--------|---------|
| `app-data` S3 bucket | AWS-managed encryption (SSE-S3) | Upgraded to KMS with CMK | ✅ Complete | CIS 2.1.1 |
| `app-data` S3 bucket | No public access block | Enabled all 4 public access controls | ✅ Complete | CIS 2.1.5 |
| `user-uploads` S3 bucket | No encryption configured | Added KMS encryption | ✅ Complete | CIS 2.1.1 |
| `user-uploads` S3 bucket | No public access block | Enabled all 4 public access controls | ✅ Complete | CIS 2.1.5 |
| `app-logs` S3 bucket | No encryption configured | Added KMS encryption | ✅ Complete | CIS 2.1.1 |
| `app-logs` S3 bucket | No public access block | Enabled all 4 public access controls | ✅ Complete | CIS 2.1.5 |
| `database` security group | PostgreSQL open to 0.0.0.0/0 | Restricted to internal CIDR blocks | ✅ Complete | CIS 5.2 |
| `database` security group | Unrestricted egress | Limited to HTTPS only | ✅ Complete | CIS 5.1 |
| All resources | Missing security classification tags | Added SecurityLevel and DataClassification | ✅ Complete | Internal |
| KMS keys | No key rotation | Enabled automatic rotation | ✅ Complete | CIS 2.7 |

## Testing & Validation

### Security Scans
- ✅ `tfsec` scan - 0 high/critical findings (down from 8)
- ✅ `checkov` compliance scan - 100% pass rate on CIS benchmarks
- ✅ AWS Config rules - All required rules pass
- ✅ No security group rules allow 0.0.0.0/0 to sensitive ports

### Functional Testing
- ✅ `terraform plan` executed successfully - 15 resources to add, 3 to modify, 0 to destroy
- ✅ Application connectivity verified - app can still access S3 and database
- ✅ KMS key permissions validated - S3 can encrypt/decrypt with new keys
- ✅ Security group connectivity tested - database accessible from app tier only
- ✅ No breaking changes - existing application functions maintained

### Terraform Plan Summary

```
Plan: 15 to add, 3 to modify, 0 to destroy.

Changes:
  + aws_kms_key.s3_encryption
  + aws_kms_alias.s3_encryption
  + aws_kms_key_policy.s3_encryption
  ~ aws_s3_bucket_server_side_encryption_configuration.app_data (algorithm change)
  + aws_s3_bucket_server_side_encryption_configuration.user_uploads
  + aws_s3_bucket_server_side_encryption_configuration.app_logs
  + aws_s3_bucket_public_access_block.app_data
  + aws_s3_bucket_public_access_block.user_uploads
  + aws_s3_bucket_public_access_block.app_logs
  ~ aws_security_group.database (ingress change)
  + aws_security_group.app_internal
  ~ tags on multiple resources
```

## Additional Context

- **Security Scan Tool**: Checkov 3.2.1, tfsec 1.28.4
- **Scan Time**: 2026-03-02 16:45:33 UTC
- **Affected Workspace**: `terraform-remediation-demo`
- **Terraform Version**: 1.7.0
- **AWS Provider Version**: 5.38.0
- **Compliance Frameworks**: CIS AWS Foundations 1.5.0, NIST 800-53 Rev 5

### Security Advisories & References
- [CIS AWS Foundations Benchmark v1.5.0](https://www.cisecurity.org/benchmark/amazon_web_services)
- [NIST 800-53 Rev 5 - SC-13 Cryptographic Protection](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-53r5.pdf)
- [AWS S3 Security Best Practices](https://docs.aws.amazon.com/AmazonS3/latest/userguide/security-best-practices.html)
- [AWS KMS Best Practices](https://docs.aws.amazon.com/kms/latest/developerguide/best-practices.html)
- [OWASP Cloud Security - Data Protection](https://owasp.org/www-project-cloud-security/)

### Related CVEs (for reference)
- **CVE-2019-5483** - S3 bucket misconfiguration leading to data exposure
- **CVE-2020-15142** - Unencrypted data at rest vulnerability
- **CVE-2021-38155** - Overly permissive security group rules

---

**Review Notes:**
- All changes implement security best practices from CIS and NIST frameworks
- No functional disruption - encryption and network changes are transparent to applications
- KMS costs estimated at ~$3/month per key + $0.03 per 10,000 API calls
- Recommended action: Approve immediately to close security gaps
- Post-merge: Run security scan to verify all findings resolved
```

**Step 6: Commit security hardening**

```bash
git add terraform/aws/ .github/pr-descriptions/security-pr.md
git commit -m "security(hardening): apply missing security controls to vulnerable resources

Security Findings Addressed:
- CIS 2.1.1: S3 buckets using AWS-managed encryption instead of customer-managed KMS
- CIS 2.1.5: S3 buckets missing public access blocks
- CIS 5.2: Database security group allowing access from 0.0.0.0/0
- Missing compliance and security classification tags

Changes Made:
- Add KMS customer-managed key for S3 encryption with automatic rotation
- Upgrade all S3 buckets to use KMS encryption
- Enable public access blocks on all S3 buckets
- Restrict database security group to internal CIDR blocks only
- Add new security group for internal app-to-app communication
- Add SecurityLevel and DataClassification tags
- Limit database egress to HTTPS only

Impact: 15 resources to add, 3 to modify, 0 to destroy
Risk: Low - Encryption and network changes are transparent to applications
Compliance: Addresses CIS AWS Foundations and NIST 800-53 requirements

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

Expected: Commit created with security changes

**Step 7: Push security branch**

```bash
git push origin security/hardening-controls
```

Expected: Branch pushed to GitHub

**Step 8: Create security PR using GitHub CLI**

```bash
gh pr create \
  --base master \
  --head security/hardening-controls \
  --title "security(hardening): apply missing security controls to vulnerable resources" \
  --body-file .github/pr-descriptions/security-pr.md \
  --label "security,hardening,terraform,compliance"
```

Expected: PR created successfully with number

**Step 9: Verify security PR**

```bash
gh pr view --web
```

Expected: Browser opens showing PR with formatted security description

---

## Task 5: Final Validation

**Step 1: List all PRs**

```bash
gh pr list
```

Expected: Shows 2 open PRs:
- fix/drift-reconciliation
- security/hardening-controls

**Step 2: Check PR status**

```bash
gh pr view <PR_NUMBER_1>
gh pr view <PR_NUMBER_2>
```

Expected: Both PRs show:
- Status: Open
- Base: master
- Labels applied
- Full description visible

**Step 3: Verify no impact on Ember app**

```bash
cd hdsproto
pnpm start
```

Expected: App starts successfully without errors

**Step 4: Return to master**

```bash
git checkout master
```

Expected: Switched to master branch

**Step 5: Verify terraform directory is isolated**

```bash
ls -la terraform/
```

Expected: Shows terraform files, no .terraform or state files

---

## Success Criteria

- ✅ Two PRs created and open on GitHub
- ✅ PR #1: Drift reconciliation with realistic Terraform changes
- ✅ PR #2: Security hardening with KMS, security groups, and compliance
- ✅ Both PRs follow wireframe format with all sections
- ✅ PR descriptions include detailed tables and technical content
- ✅ Terraform files show meaningful diffs
- ✅ All demo infrastructure isolated in `terraform/` directory
- ✅ No impact on Ember application functionality
- ✅ PRs remain open for demo purposes

## Notes for Execution

- All Terraform files are demo-only and should never be applied
- PRs will remain open indefinitely - do not merge or close
- If PR numbers are needed for linking from UI, save them after creation
- GitHub CLI (`gh`) must be authenticated before running PR create commands
- If `gh` command fails, user may need to run `gh auth login` first
