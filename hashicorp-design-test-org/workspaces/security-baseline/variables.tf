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

variable "controls" {
  type        = list(string)
  description = "Security controls"
  default     = ["encryption-at-rest", "tls-min-1-2", "least-privilege"]
}
