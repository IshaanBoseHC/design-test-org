variable "environment" {
  type        = string
  description = "Environment name"
  default     = "prod"
}

variable "registry_namespace" {
  type        = string
  description = "Private registry namespace"
  default     = "hashicorp-design"
}

variable "network_id" {
  type        = string
  description = "Network identifier"
}

variable "logging_id" {
  type        = string
  description = "Logging identifier"
}

variable "identity_id" {
  type        = string
  description = "Identity identifier"
}
