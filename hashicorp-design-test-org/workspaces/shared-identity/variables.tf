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

variable "identity_provider" {
  type        = string
  description = "Primary identity provider"
  default     = "okta"
}

variable "groups" {
  type        = list(string)
  description = "Identity groups"
  default     = ["platform-admins", "security-ops", "app-operators"]
}
