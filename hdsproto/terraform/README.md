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
