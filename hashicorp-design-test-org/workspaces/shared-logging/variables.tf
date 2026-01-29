variable "environment" {
  type        = string
  description = "Environment name"
  default     = "shared"
}

variable "registry_namespace" {
  type        = string
  description = "Private registry namespace"
  default     = "hashicorp-design"
}

variable "retention_days" {
  type        = number
  description = "Retention period"
  default     = 30
}

variable "destinations" {
  type        = list(string)
  description = "Logging destinations"
  default     = ["splunk", "s3", "datadog"]
}
